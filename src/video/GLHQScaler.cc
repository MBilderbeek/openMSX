// $Id$

#include "GLHQScaler.hh"
#include "GLUtil.hh"
#include "HQCommon.hh"
#include "FrameSource.hh"
#include "openmsx.hh"

namespace openmsx {

#include "HQ2xWeights.nn"
#include "HQ3xWeights.nn"
#include "HQ4xWeights.nn"

static byte* offsetData[3] = {
	hq2xOffsets,
	hq3xOffsets,
	hq4xOffsets,
};
static byte* weightData[3] = {
	hq2xWeights,
	hq3xWeights,
	hq4xWeights,
};

GLHQScaler::GLHQScaler()
{
	VertexShader   vertexShader  ("hq.vert");
	FragmentShader fragmentShader("hq.frag");
	scalerProgram.reset(new ShaderProgram());
	scalerProgram->attach(vertexShader);
	scalerProgram->attach(fragmentShader);
	scalerProgram->link();

	edgeTexture.reset(new Texture());
	edgeTexture->bind();
	edgeTexture->setWrapMode(false);
	glTexImage2D(GL_TEXTURE_2D,    // target
	             0,                // level
	             GL_LUMINANCE16,   // internal format
	             320,              // width
	             240,              // height
	             0,                // border
	             GL_LUMINANCE,     // format
	             GL_UNSIGNED_SHORT,// type
	             NULL);            // data

	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	byte buf[4 * 4];
	for (int i = 0; i < 3; ++i) {
		int n = i + 2;
		int n2 = n * n;
		linearizeTexture[i].reset(new Texture());
		// we need wrap mode here
		linearizeTexture[i]->bind();
		for (int j = 0; j < n2; ++j) {
			buf[j] = (int)(((256 * j + 128) / (double)n2) + 0.5);
		}
		glTexImage2D(GL_TEXTURE_2D,    // target
			     0,                // level
			     GL_LUMINANCE,     // internal format
			     n,                // width
			     n,                // height
			     0,                // border
			     GL_LUMINANCE,     // format
			     GL_UNSIGNED_BYTE, // type
			     buf);             // data

		offsetTexture[i].reset(new Texture());
		offsetTexture[i]->setWrapMode(false);
		offsetTexture[i]->bind();
		glTexImage2D(GL_TEXTURE_2D,    // target
			     0,                // level
			     GL_RGBA8,         // internal format
			     n2,               // width
			     4096,             // height
			     0,                // border
			     GL_RGBA,          // format
			     GL_UNSIGNED_BYTE, // type
			     offsetData[i]);   // data

		weightTexture[i].reset(new Texture());
		weightTexture[i]->setWrapMode(false);
		weightTexture[i]->bind();
		glTexImage2D(GL_TEXTURE_2D,    // target
			     0,                // level
			     GL_RGB8,          // internal format
			     n2,               // width
			     4096,             // height
			     0,                // border
			     GL_RGB,           // format
			     GL_UNSIGNED_BYTE, // type
			     weightData[i]);   // data
	}
	glPixelStorei(GL_UNPACK_ALIGNMENT, 4); // restore to default

#ifdef GL_VERSION_2_0
	if (GLEW_VERSION_2_0) {
		scalerProgram->activate();
		glUniform1i(scalerProgram->getUniformLocation("colorTex"),  0);
		glUniform1i(scalerProgram->getUniformLocation("edgeTex"),   1);
		glUniform1i(scalerProgram->getUniformLocation("linearTex"), 2);
		glUniform1i(scalerProgram->getUniformLocation("offsetTex"), 3);
		glUniform1i(scalerProgram->getUniformLocation("weightTex"), 4);
		glUniform2f(scalerProgram->getUniformLocation("texSize"),
		            320.0f, 2 * 240.0f);
	}
#endif
}

void GLHQScaler::scaleImage(
	ColourTexture& src,
	unsigned srcStartY, unsigned srcEndY, unsigned srcWidth,
	unsigned dstStartY, unsigned dstEndY, unsigned dstWidth)
{
	unsigned factorX = dstWidth / srcWidth; // 1 - 4
	unsigned factorY = (dstEndY - dstStartY) / (srcEndY - srcStartY);

	if ((srcWidth == 320) && (factorX > 1) && (factorX == factorY)) {
		assert(src.getHeight() == 2 * 240);
		glActiveTexture(GL_TEXTURE4);
		weightTexture[factorX - 2]->bind();
		glActiveTexture(GL_TEXTURE3);
		offsetTexture[factorX - 2]->bind();
		glActiveTexture(GL_TEXTURE2);
		linearizeTexture[factorX - 2]->bind();
		glActiveTexture(GL_TEXTURE1);
		edgeTexture->bind();
		glActiveTexture(GL_TEXTURE0);
		scalerProgram->activate();
	} else {
		scalerProgram->deactivate();
	}

	GLfloat height = src.getHeight();
	src.drawRect(0.0f,  srcStartY            / height,
	             1.0f, (srcEndY - srcStartY) / height,
	             0, dstStartY, dstWidth, dstEndY - dstStartY);
}

typedef unsigned Pixel;
static void calcInitialEdges(const Pixel* srcPrev, const Pixel* srcCurr,
                             unsigned lineWidth, word* edgeBuf)
{
	unsigned x = 0;
	Pixel c1 = srcPrev[x];
	Pixel c2 = srcCurr[x];
	word pattern = edge(c1, c2) ? (3 << (6 + 4)) : 0;
	for (/* */; x < (lineWidth - 1); ++x) {
		pattern >>= 6;
		Pixel n1 = srcPrev[x + 1];
		Pixel n2 = srcCurr[x + 1];
		if (edge(c1, c2)) pattern |= (1 << (5 + 4));
		if (edge(c1, n2)) pattern |= (1 << (6 + 4));
		if (edge(c2, n1)) pattern |= (1 << (7 + 4));
		edgeBuf[x] = pattern;
		c1 = n1; c2 = n2;
	}
	pattern >>= 6;
	if (edge(c1, c2)) pattern |= (7 << (5 + 4));
	edgeBuf[x] = pattern;
}
void GLHQScaler::uploadBlock(
	unsigned srcStartY, unsigned srcEndY, unsigned lineWidth,
	FrameSource& paintFrame)
{
	if (lineWidth != 320) return;

	word edgeBuf[320 * (240 + 1)];
	Pixel* dummy = 0;
	const Pixel* curr = paintFrame.getLinePtr(srcStartY - 1, lineWidth, dummy);
	const Pixel* next = paintFrame.getLinePtr(srcStartY + 0, lineWidth, dummy);
	calcInitialEdges(curr, next, lineWidth, edgeBuf);

	for (unsigned y = srcStartY; y < srcEndY; ++y) {
		curr = next;
		next = paintFrame.getLinePtr(y + 1, lineWidth, dummy);

		word* edges = &edgeBuf[320 * (y - srcStartY)];
		unsigned pattern = 0;
		unsigned c6 = curr[0];
		unsigned c9 = next[0];
		if (edge(c6, c9))              pattern |= 3 << (6 + 4);
		if (edges[0] & (1 << (0 + 4))) pattern |= 3 << (9 + 4);
		unsigned x = 0;
		for (/* */; x < (lineWidth - 1); ++x) {
			unsigned c5 = c6;
			unsigned c8 = c9;
			c6 = curr[x + 1];
			c9 = next[x + 1];
			pattern = (pattern >> 6) & (0x001F << 4);
			if (edge(c5, c8)) pattern |= 1 << (5 + 4);
			if (edge(c5, c9)) pattern |= 1 << (6 + 4);
			if (edge(c6, c8)) pattern |= 1 << (7 + 4);
			if (edge(c5, c6)) pattern |= 1 << (8 + 4);
			pattern |= ((edges[x] & (1 << (5 + 4))) << 6) |
				   ((edges[x] & (3 << (6 + 4))) << 3);
			edges[x + 320] = pattern | 8;
		}
		pattern = (pattern >> 6) & (0x001F << 4);
		if (edge(c6, c9)) pattern |= 7 << (5 + 4);
		pattern |= ((edges[x] & (1 << (5 + 4))) << 6) |
			   ((edges[x] & (3 << (6 + 4))) << 3);
		edges[x + 320] = pattern | 8;
	}

	edgeTexture->bind();
	glTexSubImage2D(GL_TEXTURE_2D,       // target
	                0,                   // level
	                0,                   // offset x
	                srcStartY,           // offset y
	                lineWidth,           // width
	                srcEndY - srcStartY, // height
	                GL_LUMINANCE,        // format
	                GL_UNSIGNED_SHORT,   // type
	                &edgeBuf[320]);      // data
}

} // namespace openmsx
