// $Id$

#ifndef __INFOTOPIC_HH__
#define __INFOTOPIC_HH__

#include <string>
#include <vector>

using std::string;
using std::vector;

namespace openmsx {

class CommandArgument;

class InfoTopic
{
public:
	/** Show info on this topic
	  * @param tokens Tokenized command line;
	  *     tokens[1] is the topic.
	  * @param result The result of this topic must be assigned to this
	  *               parameter.
	  * @throw CommandException Thrown when there was an error while
	  *                         executing this InfoTopic.
	  */
	virtual void execute(const vector<CommandArgument>& tokens,
	                     CommandArgument& result) const = 0;

	/** Print help for this topic.
	  * @param tokens Tokenized command line;
	  *     tokens[1] is the topic.
	  */
	virtual string help(const vector<string>& tokens) const = 0;

	/** Attempt tab completion for this topic.
	  * Default implementation does nothing.
	  * @param tokens Tokenized command line;
	  *     tokens[1] is the topic.
	  *     The last token is incomplete, this method tries to complete it.
	  */
	virtual void tabCompletion(vector<string>& /*tokens*/) const {}
};

} // namespace openmsx

#endif
