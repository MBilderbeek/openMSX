// $Id$

#ifndef __MIDIOUTNATIVE_HH__
#define __MIDIOUTNATIVE_HH__

#if defined(__WIN32__)
#include "MidiOutDevice.hh"

namespace openmsx {

class PluggingController;

class MidiOutNative : public MidiOutDevice
{
public:
	static void registerAll(PluggingController* controller);
		
	MidiOutNative(unsigned num);
	virtual ~MidiOutNative();

	// Pluggable
	virtual void plug(Connector* connector, const EmuTime& time)
		throw(PlugException);
	virtual void unplug(const EmuTime& time);
	virtual const string& getName() const;
	virtual const string& getDescription() const;

	// SerialDataInterface (part)
	virtual void recvByte(byte value, const EmuTime& time);

private:
	unsigned devidx;
	string name;
	string desc;
};

} // namespace openmsx

#endif // defined(__WIN32__)
#endif // __MIDIOUTNATIVE_HH__

