// This class implements the Intel 8255 chip
//
// * Only the 8255 is emulated, no surrounding hardware.
//   Use the class I8255Interface to do that.
// * Only mode 0 (basic input/output) is implemented

#ifndef I8255_HH
#define I8255_HH

#include "EmuTime.hh"
#include "TclCallback.hh"

#include <cstdint>

namespace openmsx {

class I8255Interface;
class StringSetting;

class I8255
{
public:
	I8255(I8255Interface& interface, EmuTime::param time,
	      StringSetting& invalidPpiModeSetting);

	// CPU side
	void reset(EmuTime::param time);
	[[nodiscard]] uint8_t read(uint8_t port, EmuTime::param time);
	[[nodiscard]] uint8_t peek(uint8_t port, EmuTime::param time) const;
	void write(uint8_t port, uint8_t value, EmuTime::param time);

	// Peripheral side, pull-interface
	// (the I8255Interface class implements the push-interface)
	uint8_t getPortA() const;
	uint8_t getPortB() const;
	uint8_t getPortC() const;

	template<typename Archive>
	void serialize(Archive& ar, unsigned version);

private:
	[[nodiscard]] uint8_t readPortA(EmuTime::param time);
	[[nodiscard]] uint8_t readPortB(EmuTime::param time);
	[[nodiscard]] uint8_t readPortC(EmuTime::param time);
	[[nodiscard]] uint8_t readControlPort(EmuTime::param time) const;
	[[nodiscard]] uint8_t peekPortA(EmuTime::param time) const;
	[[nodiscard]] uint8_t peekPortB(EmuTime::param time) const;
	[[nodiscard]] uint8_t peekPortC(EmuTime::param time) const;
	void writePortA(uint8_t value, EmuTime::param time);
	void writePortB(uint8_t value, EmuTime::param time);
	void writePortC(uint8_t value, EmuTime::param time);
	void writeControlPort(uint8_t value, EmuTime::param time);

	[[nodiscard]] uint8_t readC0(EmuTime::param time);
	[[nodiscard]] uint8_t readC1(EmuTime::param time);
	[[nodiscard]] uint8_t peekC0(EmuTime::param time) const;
	[[nodiscard]] uint8_t peekC1(EmuTime::param time) const;
	void outputPortA(uint8_t value, EmuTime::param time);
	void outputPortB(uint8_t value, EmuTime::param time);
	void outputPortC(uint8_t value, EmuTime::param time);

private:
	I8255Interface& interface;

	uint8_t control;
	uint8_t latchPortA;
	uint8_t latchPortB;
	uint8_t latchPortC;

	TclCallback ppiModeCallback;
};

} // namespace openmsx

#endif
