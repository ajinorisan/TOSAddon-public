#ifndef __GEOMETRY_SHADER_FX__
#define __GEOMETRY_SHADER_FX__

struct VSData	// VS
{
	float4x4 viewProjectionMatrix;
};
VSData g_vsData;

struct GeometryData	// VS
{
	float4x4 worldMatrix;
	float4 color;
};
GeometryData g_geometryData;

texture g_texDiffuse : register(t0);
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

struct VS_OUT
{
	float4 position : POSITION;
	float3 normal : TEXCOORD0;
	float2 uv : TEXCOORD1;
	float4 color : COLOR;
};

VS_OUT VS(in float4 inPosition : POSITION
	, in float3 inNormal : NORMAL
	, in float2 inUV : TEXCOORD0)
{
	inPosition.w = 1.f;

	VS_OUT output = (VS_OUT)0;
	output.position = mul(inPosition, g_geometryData.worldMatrix);
	output.position = mul(output.position, g_vsData.viewProjectionMatrix);
	output.normal = inNormal;
	output.uv = inUV;
	output.color = g_geometryData.color;
	return output;
}

float4 PS(in VS_OUT input) : COLOR0
{
	return input.color;
}

float4 PS_Texture(in VS_OUT input) : COLOR0
{
	return TexDiffuse(input.uv) * input.color;
}

technique Vertex
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS();
		PixelShader = compile ps_3_0 PS();
	}
};

technique Texture
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS();
		PixelShader = compile ps_3_0 PS_Texture();
	}
};

technique Vertex_Wireframe
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS();
		PixelShader = compile ps_3_0 PS();
	}
};

technique Texture_Wireframe
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS();
		PixelShader = compile ps_3_0 PS_Texture();
	}
};
#endif	//__GEOMETRY_SHADER_FX__