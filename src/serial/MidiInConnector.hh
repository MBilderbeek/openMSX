// $Id$

#ifndef __MIDIINCONNECTOR_HH__
#define __MIDIINCONNECTOR_HH__

#include "Connector.hh"
#include "SerialDataInterface.hh"
#include "MidiInDevice.hh"

namespace openmsx {


class MidiInConnector : public Connector, public SerialDataInterface
{
public:
	MidiInConnector(const string &name);
	virtual ~MidiInConnector();

	// Connector
	virtual const string& getDescription() const;
	virtual const string& getClass() const;
	virtual MidiInDevice& getPlugged() const;

	virtual bool ready() = 0;
	virtual bool acceptsData() = 0;
};

} // namespace openmsx

#endif // __MIDIINCONNECTOR_HH__
