// $Id$

#ifndef HQ2XSCALER_HH
#define HQ2XSCALER_HH

#include "Scaler2.hh"

namespace openmsx {

/** Runs the hq2x scaler algorithm.
  */
template <class Pixel>
class HQ2xScaler: public Scaler2<Pixel>
{
public:
	HQ2xScaler(SDL_PixelFormat* format);

	virtual void scale256(FrameSource& src, SDL_Surface* dst,
	                      unsigned startY, unsigned endY, bool lower);
	virtual void scale512(FrameSource& src, SDL_Surface* dst,
	                      unsigned startY, unsigned endY, bool lower);
};

} // namespace openmsx

#endif
