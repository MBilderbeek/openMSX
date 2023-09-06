#include "ImGuiMachine.hh"

#include "CustomFont.h"
#include "ImGuiCpp.hh"
#include "ImGuiManager.hh"
#include "ImGuiUtils.hh"

#include "BooleanSetting.hh"
#include "CartridgeSlotManager.hh"
#include "Debuggable.hh"
#include "Debugger.hh"
#include "GlobalSettings.hh"
#include "MSXMotherBoard.hh"
#include "Reactor.hh"
#include "RealDrive.hh"
#include "VDP.hh"
#include "VDPVRAM.hh"

#include "StringOp.hh"
#include "StringReplacer.hh"

#include <imgui_stdlib.h>
#include <imgui.h>

using namespace std::literals;


namespace openmsx {

void ImGuiMachine::showMenu(MSXMotherBoard* motherBoard)
{
	im::Menu("Machine", [&]{
		bool hasMachine = motherBoard != nullptr;

		ImGui::MenuItem("Select MSX machine ...", nullptr, &showSelectMachine);

		auto& pauseSetting = manager.getReactor().getGlobalSettings().getPauseSetting();
		bool pause = pauseSetting.getBoolean();
		if (ImGui::MenuItem("Pause", "PAUSE", &pause)) {
			pauseSetting.setBoolean(pause);
		}

		if (ImGui::MenuItem("Reset", nullptr, nullptr, hasMachine)) {
			manager.executeDelayed(TclObject("reset"));
		}
	});
}

void ImGuiMachine::paint(MSXMotherBoard* motherBoard)
{
	if (showSelectMachine) {
		paintSelectMachine(motherBoard);
	}
}

[[nodiscard]] static const std::string* getOptionalDictValue(
	const std::vector<std::pair<std::string, std::string>>& info,
	std::string_view key)
{
	auto it = ranges::find_if(info, [&](const auto& p) { return p.first == key; });
	if (it == info.end()) return {};
	return &it->second;
}


void ImGuiMachine::paintSelectMachine(MSXMotherBoard* motherBoard)
{
	ImGui::SetNextWindowSize(gl::vec2{36, 31} * ImGui::GetFontSize(), ImGuiCond_FirstUseEver);
	im::Window("Select MSX machine", &showSelectMachine, [&]{
		auto& reactor = manager.getReactor();
		auto instances = reactor.getMachineIDs();
		auto currentInstance = reactor.getMachineID();
		if (instances.size() > 1 || currentInstance.empty()) {
			ImGui::TextUnformatted("Instances:"sv);
			HelpMarker("Switch between different machine instances. Right-click to delete an instance.");
			im::Indent([&]{
				float height = (std::min(4.0f, float(instances.size())) + 0.25f) * ImGui::GetTextLineHeightWithSpacing();
				im::ListBox("##empty", {-FLT_MIN, height}, [&]{
					int i = 0;
					for (const auto& name : instances) {
						im::ID(++i, [&]{
							bool isCurrent = name == currentInstance;
							auto board = reactor.getMachine(name);
							std::string display = [&]{
								if (board) {
									auto configName = board->getMachineName();
									auto* info = findMachineInfo(configName);
									assert(info);
									auto time = (board->getCurrentTime() - EmuTime::zero()).toDouble();
									return strCat(info->displayName, " (", formatTime(time), ')');
								} else {
									return std::string(name);
								}
							}();
							if (ImGui::Selectable(display.c_str(), isCurrent)) {
								manager.executeDelayed(makeTclList("activate_machine", name));
							}
							im::PopupContextItem("instance context menu", [&]{
								if (ImGui::Selectable("Delete instance")) {
									manager.executeDelayed(makeTclList("delete_machine", name));
								}
							});
						});
					}
				});
			});
			ImGui::Separator();
		}

		if (motherBoard) {
			auto configName = motherBoard->getMachineName();
			auto* info = findMachineInfo(configName);
			assert(info);
			std::string display = strCat("Current machine: ", info->displayName);
			im::TreeNode(display.c_str(), [&]{
				printConfigInfo(*info);
			});
			if (newMachineConfig.empty()) newMachineConfig = configName;
			auto& defaultMachine = reactor.getMachineSetting();
			if (defaultMachine.getString() != configName) {
				if (ImGui::Button("Make this the default machine")) {
					defaultMachine.setValue(TclObject(configName));
				}
				simpleToolTip("Use this as the default MSX machine when openMSX starts.");
			}
			ImGui::Separator();
		}

		im::TreeNode("Available machines", ImGuiTreeNodeFlags_DefaultOpen, [&]{
			std::string filterDisplay = "filter";
			if (!filterType.empty() || !filterRegion.empty() || !filterString.empty()) strAppend(filterDisplay, ':');
			if (!filterType.empty()) strAppend(filterDisplay, ' ', filterType);
			if (!filterRegion.empty()) strAppend(filterDisplay, ' ', filterRegion);
			if (!filterString.empty()) strAppend(filterDisplay, ' ', filterString);
			strAppend(filterDisplay, "###filter");
			im::TreeNode(filterDisplay.c_str(), [&]{
				auto combo = [&](std::string& selection, zstring_view key) {
					im::Combo(key.c_str(), selection.empty() ? "--all--" : selection.c_str(), [&]{
						if (ImGui::Selectable("--all--")) {
							selection.clear();
						}
						for (const auto& type : getAllValuesFor(key)) {
							if (ImGui::Selectable(type.c_str())) {
								selection = type;
							}
						}
					});
				};
				combo(filterType, "type");
				combo(filterRegion, "region");
				ImGui::InputText(ICON_IGFD_SEARCH, &filterString);
				simpleToolTip("A list of substrings that must be part of the machine name.\n"
				              "\n"
				              "For example: enter 'pa' to search for 'Panasonic' machines. "
				              "Then refine the search by appending '<space>st' to find the 'Panasonic FS-A1ST' machine.");
			});
			im::ListBox("##list", [&]{
				auto& allMachines = getAllMachines();
				auto filteredMachines = to_vector(xrange(allMachines.size()));
				auto filter = [&](std::string_view key, const std::string& value) {
					if (value.empty()) return;
					std::erase_if(filteredMachines, [&](auto idx) {
						const auto& info = allMachines[idx].configInfo;
						const auto* val = getOptionalDictValue(info, key);
						if (!val) return true; // remove items that don't have the key
						return *val != value;
					});
				};
				filter("type", filterType);
				filter("region", filterRegion);
				if (!filterString.empty()) {
					std::erase_if(filteredMachines, [&](auto idx) {
						const auto& display = allMachines[idx].displayName;
						return !ranges::all_of(StringOp::split_view<StringOp::REMOVE_EMPTY_PARTS>(filterString, ' '),
							[&](auto part) { return StringOp::containsCaseInsensitive(display, part); });
					});
				}

				ImGuiListClipper clipper; // only draw the actually visible rows
				clipper.Begin(narrow<int>(filteredMachines.size()));
				while (clipper.Step()) {
					for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; ++i) {
						auto idx = filteredMachines[i];
						auto& info = allMachines[idx];
						bool ok = getTestResult(info).empty();
						im::StyleColor(ImGuiCol_Text, ok ? 0xFFFFFFFF : 0xFF0000FF, [&]{
							if (ImGui::Selectable(info.displayName.c_str(), info.configName == newMachineConfig, ImGuiSelectableFlags_AllowDoubleClick)) {
								newMachineConfig = info.configName;
								if (ImGui::IsMouseDoubleClicked(ImGuiMouseButton_Left)) {
									manager.executeDelayed(makeTclList("machine", newMachineConfig));
								}
							}
							im::ItemTooltip([&]{
								printConfigInfo(info);
							});
						});
					}
				}
			});
		});
		ImGui::Separator();
		im::TreeNode("Selected machine", ImGuiTreeNodeFlags_DefaultOpen, [&]{
			if (!newMachineConfig.empty()) {
				bool ok = printConfigInfo(newMachineConfig);
				ImGui::Spacing();
				im::Disabled(!ok, [&]{
					if (ImGui::Button("Replace")) {
						manager.executeDelayed(makeTclList("machine", newMachineConfig));
					}
					simpleToolTip("Replace the current machine with the selected machine. "
					              "Alternatively you can also double click in the list above.");
					ImGui::SameLine(0.0f, 10.0f);
					if (ImGui::Button("New")) {
						std::string script = strCat(
							"set id [create_machine]\n"
							"set err [catch {${id}::load_machine ", newMachineConfig, "} error_result]\n"
							"if {$err} {\n"
							"    delete_machine $id\n"
							"    error \"Error activating new machine: $error_result\"\n"
							"} else {\n"
							"    activate_machine $id\n"
							"}\n");
						manager.executeDelayed(TclObject(script));
					}
					simpleToolTip("Create a new machine instance (next to the current machine). "
					              "Later you can switch between the different instances (like different tabs in a web browser).");
				});
			}
		});
	});
}

// Similar to c++23 chunk_by(). Main difference is internal vs external iteration.
template<typename Range, typename BinaryPred, typename Action>
static void chunk_by(Range&& range, BinaryPred pred, Action action)
{
	auto it = std::begin(range);
	auto last = std::end(range);
	while (it != last) {
		auto start = it;
		auto prev = it++;
		while (it != last && pred(*prev, *it)) {
			prev = it++;
		}
		action(start, it);
	}
}

std::vector<ImGuiMachine::MachineInfo>& ImGuiMachine::getAllMachines()
{
	static constexpr auto replacer = StringReplacer::create(
		"manufacturer", "Manufacturer",
		"code",         "Product code",
		"release_year", "Release year",
		"description",  "Description",
		"type",         "Type");

	if (machineInfo.empty()) {
		const auto& configs = Reactor::getHwConfigs("machines");
		machineInfo.reserve(configs.size());
		for (const auto& config : configs) {
			auto& info = machineInfo.emplace_back();
			info.configName = config;

			// get machine meta-data
			auto& configInfo = info.configInfo;
			if (auto r = manager.execute(makeTclList("openmsx_info", "machines", config))) {
				auto first = r->begin();
				auto last = r->end();
				while (first != last) {
					auto desc = *first++;
					if (first == last) break; // shouldn't happen
					auto value = *first++;
					if (!value.empty()) {
						configInfo.emplace_back(std::string(replacer(desc)),
						                        std::string(value));
					}
				}
			}

			// Based on the above meta-data, try to construct a more
			// readable name Unfortunately this new name is no
			// longer guaranteed to be unique, we'll address this
			// below.
			auto& display = info.displayName;
			if (const auto* manufacturer = getOptionalDictValue(configInfo, "Manufacturer")) {
				strAppend(display, *manufacturer); // possibly an empty string;
			}
			if (const auto* code = getOptionalDictValue(configInfo, "Product code")) {
				if (!code->empty()) {
					if (!display.empty()) strAppend(display, ' ');
					strAppend(display, *code);
				}
			}
			if (display.empty()) display = config;
		}

		ranges::sort(machineInfo, StringOp::caseless{}, &MachineInfo::displayName);

		// make 'displayName' unique again
		auto sameDisplayName = [](MachineInfo& x, MachineInfo& y) {
			StringOp::casecmp cmp;
			return cmp(x.displayName, y.displayName);
		};
		chunk_by(machineInfo, sameDisplayName, [](auto first, auto last) {
			if (std::distance(first, last) == 1) return; // no duplicate name
			for (auto it = first; it != last; ++it) {
				strAppend(it->displayName, " (", it->configName, ')');
			}
			ranges::sort(first, last, StringOp::caseless{}, &MachineInfo::displayName);
		});
	}
	return machineInfo;
}

static void amendConfigInfo(MSXMotherBoard& mb, ImGuiMachine::MachineInfo& info)
{
	auto& configInfo = info.configInfo;

	auto& debugger = mb.getDebugger();
	unsigned ramSize = 0;
	for (const auto& [name, debuggable] : debugger.getDebuggables()) {
		if (debuggable->getDescription() == one_of("memory mapper", "ram")) {
			ramSize += debuggable->getSize();
		}
	}
	configInfo.emplace_back("RAM size", strCat(ramSize / 1024, "kB"));

	if (auto* vdp = dynamic_cast<VDP*>(mb.findDevice("VDP"))) {
		configInfo.emplace_back("VRAM size", strCat(vdp->getVRAM().getSize() / 1024, "kB"));
		configInfo.emplace_back("VDP version", vdp->getVersionString());
	}

	if (auto drives = RealDrive::getDrivesInUse(mb)) {
		configInfo.emplace_back("Disk drives", strCat(narrow<int>(drives->count())));
	}

	auto& carts = mb.getSlotManager();
	configInfo.emplace_back("Cartridge slots", strCat(carts.getNumberOfSlots()));
}

const std::string& ImGuiMachine::getTestResult(MachineInfo& info)
{
	if (!info.testResult) {
		info.testResult.emplace(); // empty string (for now)

		auto& reactor = manager.getReactor();
		manager.executeDelayed([&reactor, &info]() mutable {
			// don't create extra mb while drawing
			try {
				MSXMotherBoard mb(reactor);
				mb.loadMachine(info.configName);
				assert(info.testResult->empty());
				amendConfigInfo(mb, info);
			} catch (MSXException& e) {
				info.testResult = e.getMessage(); // error
			}
		});
	}
	return info.testResult.value();
}

std::vector<std::string> ImGuiMachine::getAllValuesFor(std::string_view key)
{
	std::vector<std::string> result;
	for (const auto& machine : getAllMachines()) {
		if (const auto* type = getOptionalDictValue(machine.configInfo, key)) {
			if (!contains(result, *type)) { // O(N^2), but that's fine
				result.emplace_back(*type);
			}
		}
	}
	ranges::sort(result, StringOp::caseless{});
	return result;
}

bool ImGuiMachine::printConfigInfo(MachineInfo& info)
{
	const auto& test = getTestResult(info);
	bool ok = test.empty();
	if (ok) {
		im::Table("##machine-info", 2, ImGuiTableFlags_SizingFixedFit, [&]{
			for (const auto& [desc, value_] : info.configInfo) {
				const auto& value = value_; // clang workaround
				if (ImGui::TableNextColumn()) {
					ImGui::TextUnformatted(desc);
				}
				if (ImGui::TableNextColumn()) {
					im::TextWrapPos(ImGui::GetFontSize() * 35.0f, [&] {
						ImGui::TextUnformatted(value);
					});
				}
			}
		});
	} else {
		im::StyleColor(ImGuiCol_Text, 0xFF0000FF, [&]{
			im::TextWrapPos(ImGui::GetFontSize() * 35.0f, [&] {
				ImGui::TextUnformatted(test);
			});
		});
	}
	return ok;
}

bool ImGuiMachine::printConfigInfo(const std::string& config)
{
	auto* info = findMachineInfo(config);
	if (!info) return false;
	return printConfigInfo(*info);
}

ImGuiMachine::MachineInfo* ImGuiMachine::findMachineInfo(std::string_view config)
{
	auto& allMachines = getAllMachines();
	auto it = ranges::find(allMachines, config, &MachineInfo::configName);
	return (it != allMachines.end()) ? &*it : nullptr;
}

} // namespace openmsx
