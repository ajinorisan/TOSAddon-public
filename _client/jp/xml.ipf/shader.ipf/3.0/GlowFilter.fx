#ifndef __IMCGEGLOW_FX__
#define __IMCGEGLOW_FX__

texture g_screenTex;
sampler ScreenSampler = sampler_state
{
	Texture = g_screenTex;
	AddressU = CLAMP;
	AddressV = CLAMP;
	AddressW = CLAMP;
	MIPFILTER = POINT;
	MINFILTER = POINT;
	MAGFILTER = POINT;
	SRGBTEXTURE = FALSE;
};
#define TexScreen(uv) pow(abs(tex2D(ScreenSampler, uv)), 2.2f)

texture g_blurTex;
sampler BlurSampler = sampler_state
{
	Texture = g_blurTex;
	AddressU = CLAMP;
	AddressV = CLAMP;
	AddressW = CLAMP;
	MIPFILTER = POINT;
	MINFILTER = POINT;
	MAGFILTER = POINT;
	SRGBTEXTURE = FALSE;
};
#define TexBlur(uv) pow(abs(tex2D(BlurSampler, uv)), 2.2f)

struct BlurData
{
	float blurBlendFactor;
	float blurPowFactor;
	float blurMax;
	float padding;
};
BlurData g_blurData;

struct VignetteData
{
	float3 vignetteColor;
	float vignetteCorrectValue;

	float vignetteMinValue;
	float vignetteMaxValue;
	float2 vignetteCenterPos;
};
VignetteData g_vignetteData;

float3 vignette(in float3 c, const float2 win_bias)
{
	float2 wpos = 2 * (win_bias - g_vignetteData.vignetteCenterPos);
	float r = 1.0 - smoothstep(g_vignetteData.vignetteMinValue, g_vignetteData.vignetteMaxValue, length(wpos.xy)) * g_vignetteData.vignetteCorrectValue;
	return (r * c) + ((1.0f - r) * g_vignetteData.vignetteColor);
}

struct PS_INPUT
{
	float2 tex : TEXCOORD0;
};

float3 ApplyGamma(float3 color)
{
	return pow(abs(color), 1.f / 2.2f);
}

float4 ApplyGamma(float4 color)
{
	return pow(abs(color), 1.f / 2.2f);
}

float4 PS_ScreenGlow(PS_INPUT input) : COLOR0
{
	float4 srcColor = TexScreen(input.tex);

	float4 blurColor = TexBlur(input.tex);
	float4 addColor = pow(abs(blurColor * g_blurData.blurBlendFactor), g_blurData.blurPowFactor);
	addColor = min(addColor, float4(g_blurData.blurMax, g_blurData.blurMax, g_blurData.blurMax, g_blurData.blurMax));
	srcColor = srcColor + addColor;

	return float4(ApplyGamma(srcColor.rgb), 1.f);
}

float4 PS_ScreenGlow_Vignette(PS_INPUT input) : COLOR0
{
	float4 srcColor = TexScreen(input.tex);

	float4 blurColor = TexBlur(input.tex);
	float4 addColor = pow(abs(blurColor * g_blurData.blurBlendFactor), g_blurData.blurPowFactor);
	addColor = min(addColor, float4(g_blurData.blurMax, g_blurData.blurMax, g_blurData.blurMax, g_blurData.blurMax));
	srcColor = srcColor + addColor;

	srcColor.rgb = vignette(srcColor.rgb, input.tex);

	return float4(ApplyGamma(srcColor.rgb), 1.f);
}

technique ScreenGlow
{
	pass P0
	{
		VertexShader = null;
		PixelShader = compile ps_3_0 PS_ScreenGlow();
	}
}

technique ScreenGlow_Vignette
{
	pass P0
	{
		VertexShader = null;
		PixelShader = compile ps_3_0 PS_ScreenGlow_Vignette();
	}
}

#endif //__IMCGEGLOW_FX__