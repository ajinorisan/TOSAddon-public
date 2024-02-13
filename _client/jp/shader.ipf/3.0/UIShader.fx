#ifndef __UI_SHADER_FX__
#define __UI_SHADER_FX__

struct VS_Contents
{
	float4x4 projectionMatrix;
};
VS_Contents g_vs_Contents;

texture g_textureUI;
sampler UISampler = sampler_state
{
	Texture = g_textureUI;
	AddressU = CLAMP;
	AddressV = CLAMP;
	AddressW = CLAMP;
	MIPFILTER = LINEAR;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	SRGBTEXTURE = FALSE;
};
#define TexUI(uv)	tex2D(UISampler, uv)
#define TexUI_Gamma(uv)	SRGBToLinear(tex2D(UISampler, uv))

texture g_textureMask;
sampler UIMaskSampler = sampler_state
{
	Texture = g_textureMask;
	AddressU = CLAMP;
	AddressV = CLAMP;
	AddressW = CLAMP;
	MIPFILTER = LINEAR;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	SRGBTEXTURE = FALSE;
};
#define TexMask(uv)	tex2D(UIMaskSampler, uv)
#define TexMask_Gamma(uv)	SRGBToLinear(tex2D(UIMaskSampler, uv))

sampler UIFontSampler = sampler_state
{
	Texture = g_textureUI;
	AddressU = CLAMP;
	AddressV = CLAMP;
	AddressW = CLAMP;
	MIPFILTER = POINT;
	MINFILTER = POINT;
	MAGFILTER = POINT;
	SRGBTEXTURE = FALSE;
};
#define TexUI_Font(uv)	tex2D(UIFontSampler, uv)
#define TexUI_Font_Gamma(uv)	SRGBToLinear(tex2D(UIFontSampler, uv))

sampler UIFontMaskSampler = sampler_state
{
	Texture = g_textureMask;
	AddressU = CLAMP;
	AddressV = CLAMP;
	AddressW = CLAMP;
	MIPFILTER = POINT;
	MINFILTER = POINT;
	MAGFILTER = POINT;
	SRGBTEXTURE = FALSE;
};
#define TexMask_Font(uv)	tex2D(UIFontMaskSampler, uv)
#define TexMask_Font_Gamma(uv)	SRGBToLinear(tex2D(UIFontMaskSampler, uv))

struct VS_INPUT
{
	float2 pos : POSITION;
	float4 color : COLOR;
	float2 uv0 : TEXCOORD0;
	float2 uv1 : TEXCOORD1;
};

struct PS_INPUT
{
	float4 pos : SV_Position;
	float4 color : COLOR0;
	float2 uv0 : TEXCOORD0;
	float2 uv1 : TEXCOORD1;
};

float4 ConvertColor(in float4 color)
{
	return float4(color.b, color.g, color.r, color.a);
}

PS_INPUT VS(VS_INPUT input)
{
	PS_INPUT output;
	output.pos = mul(g_vs_Contents.projectionMatrix, float4(input.pos.xy - 0.5f, 0.f, 1.f));
	output.color = ConvertColor(input.color);
	output.uv0 = input.uv0;
	output.uv1 = input.uv1;
	return output;
}

float4 SRGBToLinear(in float4 color)
{
	return float4(pow(abs(color.rgb), 2.2f), color.a);
}

float4 LinearToSRGB(in float4 color)
{
	return float4(pow(abs(color.rgb), 1.f / 2.2f), color.a);
}

float4 PS_Diffuse(PS_INPUT input) : COLOR0
{
	return input.color;
}

float4 PS_Frame(PS_INPUT input) : COLOR0
{
	return LinearToSRGB(input.color * TexUI(input.uv0));
}

float4 PS_UI(PS_INPUT input) : COLOR0
{
	return input.color * TexUI_Gamma(input.uv0);
}

float4 PS_UI_Mask(PS_INPUT input) : COLOR0
{
	float4 result = input.color * TexUI_Gamma(input.uv0);
	float4 mask = TexMask_Gamma(input.uv1);
	result.a *= mask.a;
	return result;
}

float4 PS_UI_Font(PS_INPUT input) : COLOR0
{
	return input.color * TexUI_Font_Gamma(input.uv0);
}

float4 PS_UI_FontMask(PS_INPUT input) : COLOR0
{
	float4 ui = TexUI_Font(input.uv0);
	float4 result = input.color * ui;

	float4 mask = TexMask_Font(input.uv1);
	result.rgb *= mask.rgb;
	result.a = mask.a;
	return result;
}

technique Diffuse
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS();
		PixelShader = compile ps_3_0 PS_Diffuse();
	}
};

technique Normal
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS();
		PixelShader = compile ps_3_0 PS_UI();
	}
};

technique Normal_Mask
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS();
		PixelShader = compile ps_3_0 PS_UI_Mask();
	}
};

technique Font
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS();
		PixelShader = compile ps_3_0 PS_UI_Font();
	}
};

technique Font_Mask
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS();
		PixelShader = compile ps_3_0 PS_UI_FontMask();
	}
};

technique Frame
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS();
		PixelShader = compile ps_3_0 PS_Frame();
	}
};

#endif	//__UI_SHADER_FX__