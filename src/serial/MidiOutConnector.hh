// $Id$

#ifndef __MIDIOUTCONNECTOR_HH__
#define __MIDIOUTCONNECTOR_HH__

#include "Connector.hh"
#include "SerialDataInterface.hh"
#include "MidiOutDevice.hh"

namespace openmsx {

class MidiOutConnector : public Connector, public SerialDataInterface
{
public:
	MidiOutConnector(const string& name);
	virtual ~MidiOutConnector();

	// Connector
	virtual const string& getDescription() const;
	virtual const string& getClass() const;
	virtual MidiOutDevice& getPlugged() const;

	// SerialDataInterface
	virtual void setDataBits(DataBits bits);
	virtual void setStopBits(StopBits bits);
	virtual void setParityBit(bool enable, ParityBit parity);
	virtual void recvByte(byte value, const EmuTime& time);
};

} // namespace openmsx

#endif // __MIDIOUTCONNECTOR_HH__
