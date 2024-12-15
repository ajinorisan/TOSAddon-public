#ifndef __CONTENTS_SHADER_FX__
#define __CONTENTS_SHADER_FX__

struct CreateMap
{
	float multiplyRatio;
	float textureSize;
	float worldSize;
	float padding;
};
CreateMap g_createMap;

struct Revealmap
{
	float2 centerPosition;
	float hypotenuseLength;
	float textureSize;
};
Revealmap g_revealMap;

texture g_texCreateMap_Background;
sampler CreateMapSampler = sampler_state
{
	Texture = g_texCreateMap_Background;
	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
	MIPFILTER = POINT;
	MINFILTER = POINT;
	MAGFILTER = POINT;
	SRGBTEXTURE = FALSE;
};
#define TexBackground(uv)	tex2D(CreateMapSampler, uv)

texture g_texMap;
sampler MapSampler = sampler_state
{
	Texture = g_texMap;
	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
	MIPFILTER = POINT;
	MINFILTER = POINT;
	MAGFILTER = POINT;
	SRGBTEXTURE = FALSE;
};
#define TexMap(uv)	tex2D(MapSampler, uv)

float2 RotateCoordinate(float tx, float ty, float cx, float cy)
{
	// 135도
	static const float rotateValue_sin = 0.70710678118654752440084436210485f;
	static const float rotateValue_cos = -0.70710678118654752440084436210485f;

	tx -= cx;
	ty -= cy;

	float x = tx * rotateValue_cos - ty * rotateValue_sin + cx;
	float y = ty * rotateValue_cos + tx * rotateValue_sin + cy;
	return float2(x, y);
}

float2 ConvertToMiniMapPos(in float2 pos, float multiplyRatio, float worldSize)
{
	float2 result = RotateCoordinate(pos.x, pos.y, 0, 0);
	result /= worldSize;
	result *= -1.f;
	result *= multiplyRatio;
	return result;
}

struct VS_OUT
{
	float4 position : SV_Position;
	float4 pos : TEXCOORD0;
	float4 color : COLOR0;
};

VS_OUT VS_CreateMap(in float4 inPosition : POSITION, in float4 inColor : COLOR)
{
	VS_OUT output = (VS_OUT)0;

	float2 pos = ConvertToMiniMapPos(inPosition.xz, g_createMap.multiplyRatio, g_createMap.worldSize);
	output.position = float4(pos, 0.f, 1.f);
	return output;
}

float4 PS_CreateMap(VS_OUT input) : COLOR0
{
	return TexBackground(input.position.xy / g_createMap.textureSize);
}

// TextureSize 가 512 일때를 기준으로 한 최소 아웃라인 사이즈
static const float OutlineSize = 0.0065f;

VS_OUT VS_CreateMap_Outline1(in float4 inPosition : POSITION, in float4 inColor : COLOR)
{
	VS_OUT output = VS_CreateMap(inPosition, inColor);
	output.position.x -= OutlineSize / (g_createMap.textureSize / 512.f);
	return output;
}

VS_OUT VS_CreateMap_Outline2(in float4 inPosition : POSITION, in float4 inColor : COLOR)
{
	VS_OUT output = VS_CreateMap(inPosition, inColor);
	output.position.y -= OutlineSize / (g_createMap.textureSize / 512.f);
	return output;
}

VS_OUT VS_CreateMap_Outline3(in float4 inPosition : POSITION, in float4 inColor : COLOR)
{
	VS_OUT output = VS_CreateMap(inPosition, inColor);
	output.position.x += OutlineSize / (g_createMap.textureSize / 512.f);
	return output;
}

VS_OUT VS_CreateMap_Outline4(in float4 inPosition : POSITION, in float4 inColor : COLOR)
{
	VS_OUT output = VS_CreateMap(inPosition, inColor);
	output.position.y += OutlineSize / (g_createMap.textureSize / 512.f);
	return output;
}

float4 PS_CreateMap_Outline(in VS_OUT input) : COLOR0
{
	return float4(0.5f, 0.25f, 0.25f, 1.f);
}

VS_OUT VS_RevealMap(in float4 inPosition : POSITION
	, in float4 inColor : COLOR)
{
	VS_OUT output = (VS_OUT)0;

	float2 centerPosition = (g_revealMap.centerPosition - (g_revealMap.textureSize / 2)) * 2;
	float2 pos = (centerPosition + (inPosition.xy * g_revealMap.hypotenuseLength * 2.2f)) / g_revealMap.textureSize;
	pos.y *= -1.f;
	output.position = float4(pos, 0.f, 1.f);
	return output;
}

float4 PS_RevealMap(in VS_OUT input) : COLOR0
{
	float2 pos = input.position.xy / g_revealMap.textureSize;

	float4 color = TexMap(pos);
	clip(color.a - 1e-5f);

	float hypotenuseLength = g_revealMap.hypotenuseLength / g_revealMap.textureSize;
	float alphaLine = hypotenuseLength * 1.25f;

	float2 centerPosition = g_revealMap.centerPosition / g_revealMap.textureSize;
	float distance = length(centerPosition - pos);
	
	float step = pow(smoothstep(0.6f, 1.f, distance / alphaLine), 2);
	float alpha = clamp(1.f - step, 0.f, 1.f);
	clip(alpha - 1e-5f);

	color.a = alpha;
	return color;
}

technique CreateMapTech
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_CreateMap_Outline1();
		PixelShader = compile ps_3_0 PS_CreateMap_Outline();
	}

	pass P1
	{
		VertexShader = compile vs_3_0 VS_CreateMap_Outline2();
		PixelShader = compile ps_3_0 PS_CreateMap_Outline();
	}

	pass P2
	{
		VertexShader = compile vs_3_0 VS_CreateMap_Outline3();
		PixelShader = compile ps_3_0 PS_CreateMap_Outline();
	}

	pass P3
	{
		VertexShader = compile vs_3_0 VS_CreateMap_Outline4();
		PixelShader = compile ps_3_0 PS_CreateMap_Outline();
	}

	pass P4
	{
		VertexShader = compile vs_3_0 VS_CreateMap();
		PixelShader = compile ps_3_0 PS_CreateMap();
	}
};

technique RevealMapTech
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_RevealMap();
		PixelShader = compile ps_3_0 PS_RevealMap();
	}
};

#endif	//__CONTENTS_SHADER_FX__