// $Id$

#ifndef __GLSNOW_HH__
#define __GLSNOW_HH__

#include "Layer.hh"
#include "GLUtil.hh"

namespace openmsx {

/** Snow effect for background layer.
  */
class GLSnow: public Layer
{
public:
	GLSnow();
	virtual ~GLSnow();

	// Layer interface:
	virtual void paint();
	virtual const std::string& getName();

private:
	GLuint noiseTextureId;
};

} // namespace openmsx

#endif // __GLSNOW_HH__
