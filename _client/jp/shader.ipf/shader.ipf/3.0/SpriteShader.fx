#ifndef __SPRITE_SHADER_FX__
#define __SPRITE_SHADER_FX__

struct VSData	// PS
{
	float4x4 viewProjectionMatrix;
};
VSData g_vsData;

struct PSData	// PS
{
	float4 lightColor;
	float2 lightMap_Length;
	float2 lightMap_Offset;
};
PSData g_psData;

struct InstanceData
{
	float2 textureSize;
	float2 padding;

	float4 rect;

	float4 worldPosition[32];
	float4 color[32];
	float4x4 transform[32];
};
InstanceData g_InstanceData;

texture g_texDiffuse;
sampler DiffuseSampler = sampler_state
{
	Texture = g_texDiffuse;
	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
	MIPFILTER = LINEAR;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	SRGBTEXTURE = FALSE;
};
#define TexDiffuse(uv)	tex2D(DiffuseSampler, uv)
#define TexDiffuseLv(uv, lv)	tex2Dlod(DiffuseSampler, float4(uv, 0, lv))

texture g_texLightMap;
sampler LightMapSampler = sampler_state
{
	Texture = g_texLightMap;
	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
	MIPFILTER = LINEAR;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	SRGBTEXTURE = FALSE;
};
#define TexLightMap(uv)	tex2Dlod(LightMapSampler, float4(uv, 0, 0))

struct VS_OUT
{
	float4 position : POSITION;
	float2 texcoord : TEXCOORD0;
	float4 color : COLOR;
	float4 posW : TEXCOORD1;
};

float4 ConvertColor(in float4 color)
{
	return float4(color.b, color.g, color.r, color.a);
}

VS_OUT VS(in float4 inPosition : POSITION
	, in float4 inColor : COLOR0
	, in float2 inTexCoord : TEXCOORD0
	, in float _InstanceID : TEXCOORD1)
{
	int InstanceID = (int)(_InstanceID + 1e-5f);
	float4 positionSS = float4(inPosition.xy * g_InstanceData.rect.zw, 0.f, 1.f);
	positionSS = mul(positionSS, g_InstanceData.transform[InstanceID]);

	float4 positionDS = positionSS;
	positionDS = positionDS * 2.f - 1.f;

	float2 outTexCoord = inTexCoord;
	outTexCoord.xy *= g_InstanceData.rect.zw / g_InstanceData.textureSize;
	outTexCoord.xy += g_InstanceData.rect.xy / g_InstanceData.textureSize;

	VS_OUT output;
	output.position = positionDS;
	output.texcoord = outTexCoord;
	output.color = g_InstanceData.color[InstanceID];
	output.posW = g_InstanceData.worldPosition[InstanceID];
	return output;
}

float4 PS(in VS_OUT input) : COLOR0
{
	float4 color = TexDiffuse(input.texcoord) * input.color;

	color.rgb *= g_psData.lightColor.rgb * g_psData.lightColor.w;

	if (g_psData.lightMap_Length.x != 0.f && g_psData.lightMap_Length.y != 0.f)
	{
		float2 lightMapUV = 0.f;
		lightMapUV.x = clamp(((g_psData.lightMap_Length.x / 2.f + input.posW.x - g_psData.lightMap_Offset.x) / g_psData.lightMap_Length.x), 0.f, 1.f);
		lightMapUV.y = clamp(((g_psData.lightMap_Length.y / 2.f - input.posW.z + g_psData.lightMap_Offset.y) / g_psData.lightMap_Length.y), 0.f, 1.f);
		float4 lightColor = TexLightMap(lightMapUV);
		lightColor.rgb = pow(abs(lightColor.xyz), 1.f / 1.4f) + 0.2f;
		color.rgb *= lightColor.rgb;
	}
	return color;
}

struct VS_OUT_Quad
{
	float4 position : POSITION;
	float2 texcoord : TEXCOORD0;
	float4 color : COLOR;
};

VS_OUT_Quad VS_Quad(in float4 inPosition : POSITION
	, in float4 inColor : COLOR0
	, in float2 inTexCoord : TEXCOORD0)
{
	VS_OUT_Quad output = (VS_OUT_Quad)0;
	output.position = mul(inPosition, g_vsData.viewProjectionMatrix);
	output.color = inColor;
	output.texcoord = inTexCoord;
	return output;
}

float4 PS_Quad(in VS_OUT_Quad input) : COLOR0
{
	return TexDiffuse(input.texcoord) * input.color;
}

technique Sprite
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS();
		PixelShader = compile ps_3_0 PS();
	}
};

technique Quad
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Quad();
		PixelShader = compile ps_3_0 PS_Quad();
	}
};

#endif	//__SPRITE_SHADER_FX__