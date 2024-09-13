struct Contents
{
	float2 sourceDimensions;
	float2 padding;
};
Contents g_contents;

texture g_texColor;
sampler PointSampler = sampler_state
{
	Texture = g_texColor;
	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
	MIPFILTER = POINT;
	MINFILTER = POINT;
	MAGFILTER = POINT;
	SRGBTEXTURE = FALSE;
};

sampler LinearSampler = sampler_state
{
	Texture = g_texColor;
	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
	MIPFILTER = LINEAR;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	SRGBTEXTURE = FALSE;
};

#ifndef IS_DECODE_LUMINANCE
#define IS_DECODE_LUMINANCE 0
#endif

static const float g_fOffsets[4] = { -1.5f, -0.5f, 0.5f, 1.5f };

// Downscales to 1/16 size, using 16 samples
float4 DownscalePS(float2 tex : TEXCOORD0) : COLOR0
{
	float4 color = 0.f;
	for (int x = 0; x < 4; ++x)
	{
		for (int y = 0; y < 4; ++y)
		{
			float2 f2Offset = float2(g_fOffsets[x], g_fOffsets[y]) / g_contents.sourceDimensions;
			float4 f4Sample = tex2D(PointSampler, tex + f2Offset);
			color += f4Sample;
		}
	}

	color /= 16.f;

#if IS_DECODE_LUMINANCE == 1
	color = float4(exp(color.r), 1.f, 1.f, 1.f);
#endif

	return color;
}

// Downscales to 1/16 size, using 16 samples
float4 DownscaleLuminancePS(float2 tex : TEXCOORD0) : COLOR0
{
	float4 color = DownscalePS(tex);

	color = float4(exp(color.r), 1.f, 1.f, 1.f);

	return color;
}

// Upscales or downscales using hardware bilinear filtering
float4 HWScalePS(float2 tex : TEXCOORD0) : COLOR0
{
	return tex2D(LinearSampler, tex);
}

technique Downscale
{
	pass P0
	{
		VertexShader = null;
		PixelShader = compile ps_3_0 DownscalePS();
	}
}

technique DownscaleLuminance
{
	pass P0
	{
		VertexShader = null;
		PixelShader = compile ps_3_0 DownscaleLuminancePS();
	}
}

technique HWScale
{
	pass P0
	{
		VertexShader = null;
		PixelShader = compile ps_3_0 HWScalePS();
	}
}