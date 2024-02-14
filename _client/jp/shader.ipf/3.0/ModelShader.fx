#ifndef __MODELSHADER_HLSL__
#define __MODELSHADER_HLSL__

struct VSData	// VS
{
	float4x4 viewMatrix;
	float4x4 invViewMatrix;
	float4x4 viewProjMatrix;
	float4x4 angleMatrix;

	float4 fogDist;
	float cameraDistance;
};
VSData g_vsData;

struct PSData	// PS
{
	float4 fogColor;
	float2 lightMap_Length;
	float2 lightMap_Offset;

	float4 lightColor;
	float lightCharacterMultiply;
	float3 lightDir;

	float groundWetness;
	float cloudAmount;
	float2 windUvOffset;
	float rainfallAmount; // 비 안내리면 -1, 내리면 0~1
	float windMagnitude; // 0~1 범위로 정규화된 바람 세기
	float groundSnowAmount;
};
PSData g_psData;

struct EncodedTransformData
{
	float4 matrix1;
	float4 matrix2;
	float4 matrix3;
};

struct RenderData
{
	float4 blendColor;
	float4 blendColorAdd;
	float4 auraColor;
	float4 auraValue;	//(x : factor, y : auraTime, z : item factor offset)
	float4 skinBlendColor;
	float4 faceUV;
	float4 outlineColor;	// w : isEnable

	uint vtfID;
	float alphaBlending;
	float timeStamp;
	uint useUvAnimMask;

	EncodedTransformData uvAnimationTransformData;
};

struct ModelInstanceData
{
	EncodedTransformData worldTransformData;
	RenderData renderData;
};

// Instancing.h 의 eMaxInstancingCount 값과 일치 시켜줘야한다.
#ifndef eMaxInstancingCount
#define eMaxInstancingCount 32
#endif

#ifdef ENABLE_INSTANCING
ModelInstanceData g_modelInstanceData[eMaxInstancingCount];
#else
ModelInstanceData g_modelInstanceData;
#endif

#ifdef ENABLE_CHARACTER_RENDER

struct CharacterData	// VS, PS
{
	float3 midPosition;
	float depthDistanceValue;

	float4 farValue;
	float4 outlineValue;
};
CharacterData g_characterData;

#endif

#ifdef ENABLE_2D

struct Render2DData
{
	EncodedTransformData billBoardTransformData;
	EncodedTransformData charViewProjTransformData;
	float4 pivot;
};

#ifdef ENABLE_INSTANCING
Render2DData g_render2DData[eMaxInstancingCount];
#else
Render2DData g_render2DData;
#endif
#endif

#ifdef ENABLE_MATERIAL_CONFIG
struct MaterialConfig	// VS, PS
{
	float4 color;
	float4 headColor;
	float fallOffMultiplyValue;
	float powValue;
	float colorMultiplyValue;
	float padding;
};
MaterialConfig g_materialConfig;
#endif

#if defined(ENABLE_HEIGHT) || defined(ENABLE_GRASS)
struct HeightMapData	// VS
{
	float size;
	float offsetX;
	float offsetY;
	float top;

	float bottom;
	float3 padding;
};
HeightMapData g_heightMapData;
#endif

#ifdef ENABLE_WATER
struct WaterData	// VS, PS
{
#ifdef ENABLE_WATER_NEW
	float4 color;

	float rimMin;
	float rimMax;
	float fresnelExp;
	float refractionScale;

	float2 waveSpeed;
	float waveScale;
	float uvScale;
	float maxLevel;
#else // #ifdef ENABLE_WATER_NEW
	float2 diffDir;

	float2 swayRange;
	float swaySpeed;
	float swayPower;

	float2 refractionDir;
	float refractionNormalSize;
	float refractionPower;

	float2 sprayDir;
	float sprayNormalSize;
	float sprayPower;
	float sprayRange;
	float padding1;

	float3 sprayColor;
	float padding2;
#endif // #ifdef ENABLE_WATER_NEW
};
WaterData g_waterData;
#endif

#ifdef ENABLE_GRASS
struct GrassData	// VS
{
	float windPower;
	float time;
	float timeOffset;
	float windDir;
};
GrassData g_grassData;
#endif

#ifdef ENABLE_SKINNING
texture g_texVTF;
sampler VTFSampler = sampler_state
{
	Texture = g_texVTF;
	AddressU = CLAMP;
	AddressV = CLAMP;
	AddressW = CLAMP;
	MIPFILTER = POINT;
	MINFILTER = POINT;
	MAGFILTER = POINT;
	SRGBTEXTURE = FALSE;
};
#define TexVTF(u, v)	tex2Dlod(VTFSampler, float4(u, v, 0, 0))
#endif

#ifdef ENABLE_DIFFUSETEX
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
#define TexDiffuse(uv)	tex2Dlod(DiffuseSampler, float4(uv, 0, 0))
#endif

#ifdef ENABLE_DIFFUSETEX_ANIMATION
texture g_texUvAnimationMask;
sampler AnimationMaskSampler = sampler_state
{
	Texture = g_texUvAnimationMask;
	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
	MIPFILTER = LINEAR;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	SRGBTEXTURE = FALSE;
};
#define TexUvAnimationMask(uv)	tex2Dlod(AnimationMaskSampler, float4(uv, 0, 0))
#endif

#ifdef ENABLE_SKIN_MASK_TEX
texture g_texDiffuse_SkinMask;
sampler SkinMaskSampler = sampler_state
{
	Texture = g_texDiffuse_SkinMask;
	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
	MIPFILTER = LINEAR;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	SRGBTEXTURE = FALSE;
};
#define TexDiffuseSkinMask(uv)	tex2D(SkinMaskSampler, uv)
#endif

#ifdef ENABLE_ENVTEX
texture g_texEnvironment;
sampler EnvironmentSampler = sampler_state
{
	Texture = g_texEnvironment;
	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
	MIPFILTER = LINEAR;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	SRGBTEXTURE = FALSE;
};
#define TexEnvironment(uv)	tex2D(EnvironmentSampler, uv)
#endif

#ifdef ENABLE_MATERIAL_CONFIG
texture g_texMaterialConfig;
sampler MaterialConfigSampler = sampler_state
{
	Texture = g_texMaterialConfig;
	AddressU = BORDER;
	AddressV = BORDER;
	AddressW = BORDER;
	MIPFILTER = LINEAR;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	SRGBTEXTURE = FALSE;
};
#define TexMaterialConfig(uv)	tex2D(MaterialConfigSampler, uv)
#endif

#ifdef ENABLE_STATICSHADOWTEX
texture g_texStaticShadow;
sampler StaticShadowSampler = sampler_state
{
	Texture = g_texStaticShadow;
	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
	MIPFILTER = LINEAR;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	SRGBTEXTURE = FALSE;
};
#define TexStaticShadow(uv)	tex2Dlod(StaticShadowSampler, float4(uv, 0, 0))
#endif

texture g_texWaterNormal;
sampler WaterNormalSampler = sampler_state
{
	Texture = g_texWaterNormal;
	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
	MIPFILTER = LINEAR;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	SRGBTEXTURE = FALSE;
};
#define TexWaterNormal(uv)	tex2D(WaterNormalSampler, uv)

#ifdef ENABLE_WATER
texture g_texWaterDepth;
sampler WaterDepthSampler = sampler_state
{
	Texture = g_texWaterDepth;
	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
	MIPFILTER = LINEAR;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	SRGBTEXTURE = FALSE;
};
#define TexWaterDepth(uv)	tex2D(WaterDepthSampler, uv)
#endif // ENABLE_WATER

#ifdef ENABLE_GRASS
texture g_texHeight;
sampler HeightSampler = sampler_state
{
	Texture = g_texHeight;
	AddressU = CLAMP;
	AddressV = CLAMP;
	AddressW = CLAMP;
	MIPFILTER = LINEAR;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	SRGBTEXTURE = FALSE;
};
#define TexHeight(uv)	tex2D(HeightSampler, uv)
#endif

texture g_texScreen;
sampler ScreenSampler = sampler_state
{
	Texture = g_texScreen;
	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
	MIPFILTER = LINEAR;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	SRGBTEXTURE = FALSE;
};
#define TexScreen(uv)	tex2Dlod(ScreenSampler, float4(uv, 0, 0))

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

texture g_texPerlinNoise;
sampler PerlinNoiseSampler = sampler_state
{
	Texture = g_texPerlinNoise;
	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
	MIPFILTER = LINEAR;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	SRGBTEXTURE = FALSE;
};
#define TexPerlinNoise(uv) tex2D(PerlinNoiseSampler, uv).r
#define TexPerlinNoiseOffset(uv, offset) tex2D(PerlinNoiseSampler, uv + offset * float2(0.001953125, 0.001953125)).r

texture g_texRainRipples;
sampler RainRipplesSampler = sampler_state
{
	Texture = g_texRainRipples;
	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
	MIPFILTER = LINEAR;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	SRGBTEXTURE = FALSE;
};
#define TexRainRipples(uv) tex2D(RainRipplesSampler, uv)

texture g_texSnow;
sampler SnowSampler = sampler_state
{
	Texture = g_texSnow;
	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
	MIPFILTER = LINEAR;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	SRGBTEXTURE = FALSE;
};
#define TexSnow(uv) tex2D(SnowSampler, uv)

#ifdef ENABLE_INSTANCING
#define GetInstData(input) g_modelInstanceData[input.InstanceID]
#else
#define GetInstData(input) g_modelInstanceData
#endif

float4x4 DecodeMatrix(in float4 encodedMatrix0, in float4 encodedMatrix1, in float4 encodedMatrix2)
{
	return float4x4(float4(encodedMatrix0.xyz, 0.f),
		float4(encodedMatrix1.xyz, 0.f),
		float4(encodedMatrix2.xyz, 0.f),
		float4(encodedMatrix0.w, encodedMatrix1.w, encodedMatrix2.w, 1.f));
}

float4x4 DecodeMatrix(in EncodedTransformData transformData)
{
	return DecodeMatrix(transformData.matrix1, transformData.matrix2, transformData.matrix3);
}

#ifdef ENABLE_SKINNING
#define VTF_WIDTH 1024

float4x4 LoadBoneMatrix(in uint vtfID, in uint bone)
{
	const uint idx = vtfID + bone;
	const uint OffsetWidth = VTF_WIDTH / 4;
	const uint OffsetHeight = VTF_WIDTH / 4;

	float4 uvCol = float4(((float)((idx % OffsetWidth) * 4) + 0.5f) / VTF_WIDTH, ((float)((idx / OffsetHeight)) + 0.5f) / VTF_WIDTH, 0.f, 0);
	float4 mat1 = tex2Dlod(VTFSampler, uvCol);
	float4 mat2 = tex2Dlod(VTFSampler, uvCol + float4(1.f / VTF_WIDTH, 0.f, 0.f, 0));
	float4 mat3 = tex2Dlod(VTFSampler, uvCol + float4(2.f / VTF_WIDTH, 0.f, 0.f, 0));

	return DecodeMatrix(mat1, mat2, mat3);
}

void ComputeSkinning(in float4 position
	, in float3 normal
	, in float4 blendWeight
	, in uint4 blendIndices
	, in uint vtfID
	, inout float4 pos_out
	, inout float3 normal_out
)
{
	pos_out = (float4)0;
	normal_out = (float3)0;

	float4x4 m;

	[unroll]
	for (int i = 0; i < 4; ++i)
	{
		m = LoadBoneMatrix(vtfID, blendIndices[i]);
		pos_out += mul(position, m) * blendWeight[i];
		normal_out += mul(normal, (float3x3)m) * blendWeight[i];
	}
}
#endif

#ifdef ENABLE_2D	// 캐릭터 2D 렌더링
float4 CalcWVP(in float4 PosW, in float4x4 viewMatrix, in float4x4 viewProjMatrix, in float4x4 charViewProjMatrix, in float4x4 billboardMatrix, in float4 pivotPoint, out float4 posWV)
{
	float worldPosY = PosW.y;
	PosW = mul(PosW, charViewProjMatrix);
	PosW /= PosW.w;
	PosW.z = 0.f;	// 빌보드로 만듦
	PosW.y += 0.4f;  // 캐릭터 발 위치를 맞추기 위한 상수
	PosW = mul(PosW, billboardMatrix);
	posWV = mul(PosW, viewMatrix);
	PosW = mul(PosW, viewProjMatrix);
	// (Local Z - 카메라 거리 : Z값을 0 앞뒤로 맞추기 위함) * 적당히 납작하게 만들기 위한 상수 - 깊이 보정값

	float uprate = 1.1;
	float pivotOffset = 100;
	float4 pivotMul = mul(float4(pivotPoint.x, (worldPosY - pivotPoint.y + pivotOffset) * uprate + pivotPoint.y - pivotOffset, pivotPoint.z, 1), viewProjMatrix);
	float defz = pivotMul.z / pivotMul.w;
	PosW.z = defz * PosW.w;
	return PosW;
}
#else
float4 CalcWVP(in float4 PosW, in float4x4 viewMatrix, in float4x4 viewProjMatrix, out float4 posWV)
{
	posWV = mul(PosW, viewMatrix);
	return mul(PosW, viewProjMatrix);
}
#endif

#ifdef ENABLE_DIFFUSETEX_ANIMATION
void SetDiffuseTexCoord(in float2 texCoord, in float4x4 uvAnimationMatrix, out float4 outTexCoord)
{
	outTexCoord.xy = mul(float4(texCoord.xy, 1.f, 1.f), uvAnimationMatrix).xy;
	outTexCoord.zw = texCoord;
}
#else
void SetDiffuseTexCoord(in float2 texCoord, out float4 outTexCoord)
{
	outTexCoord = float4(texCoord.xy, 0.f, 0.f);
}
#endif

//g_vsData.fogDist
//x = fog Start
//y = fog End
//z = End - Start
//w = 사용하지 않음.
float GetFogValue(in float4 fogDist, in float viewRange)
{
	return (fogDist.y - viewRange) / (fogDist.z);
}

float4 CalcDepth(in float depth, in float worldPosY, in float4 posWV)
{
	float4 Out = 0;
	Out.r = depth * 0.001f;
	Out.g = length(posWV.xyz) * 0.001f;
	Out.b = (worldPosY + 300) * 0.001f;
	Out.a = 1.f;
	return Out;
}

float FallOff(float3 normal, float3 eyevec)
{
	return max(0.f, dot(normal, eyevec));
}

#ifdef ENABLE_MATERIAL_CONFIG
float4 MaterialConfigColorHead(in float4 outcolor, in float falloff)
{
	outcolor.rgb = (outcolor.r + outcolor.g + outcolor.b) / 3;

	falloff = smoothstep(0.2f, 0.4f, falloff) * 0.8;
	falloff -= (1 - smoothstep(0.f, 0.3f, outcolor.r));

	outcolor.rgb += (1 - falloff) * g_materialConfig.fallOffMultiplyValue * 1.3;
	outcolor.rgb *= g_materialConfig.headColor.rgb * g_materialConfig.colorMultiplyValue;

	outcolor.rgb = pow(abs(outcolor.rgb), g_materialConfig.powValue);

	return outcolor;
}

float4 MaterialConfigColor(in float4 outcolor, in float2 uv, in float falloff)
{
	outcolor.rgb = (outcolor.r + outcolor.g + outcolor.b) / 3;

	falloff = smoothstep(0.2f, 0.4f, falloff) * 0.8;
	falloff -= (1 - smoothstep(0.f, 0.3f, outcolor.r));

	outcolor.rgb += (1 - falloff) * g_materialConfig.fallOffMultiplyValue * 1.3;
	outcolor.rgb *= g_materialConfig.color.rgb * g_materialConfig.colorMultiplyValue;

	outcolor.rgb = pow(abs(outcolor.rgb), g_materialConfig.powValue);

#ifdef ENABLE_SKINNING
	float4 value = TexMaterialConfig(uv);
	outcolor.rgb = outcolor.rgb * (1 - value.a) + value.rgb * (value.a);
#endif

	return outcolor;
}
#endif

float3 RGBToHSL(float3 RGB)
{
	float3 HSL = 0.f;
	float U = -min(RGB.r, min(RGB.g, RGB.b));
	float V = max(RGB.r, max(RGB.g, RGB.b));
	HSL.z = (V - U) * 0.5;
	float C = V + U;
	if (abs(C) < 1e-5f)
		return HSL;

	float3 Delta = (V - RGB) / C;
	Delta.rgb -= Delta.brg;
	Delta.rgb += float3(2, 4, 6);
	Delta.brg = step(V, RGB) * Delta.brg;
	HSL.x = max(Delta.r, max(Delta.g, Delta.b));
	HSL.x = frac(HSL.x / 6);
	HSL.y = C / (1 - abs(2 * HSL.z - 1));

	return HSL;
}

float3 Hue(float H)
{
	float R = abs(H * 6 - 3) - 1;
	float G = 2 - abs(H * 6 - 2);
	float B = 2 - abs(H * 6 - 4);
	return saturate(float3(R, G, B));
}

float3 HSLToRGB(float3 HSL)
{
	float3 RGB = Hue(HSL.x);
	float C = (1 - abs(2 * HSL.z - 1)) * HSL.y;
	return (RGB - 0.5) * C + HSL.z;
}

float3 hueadj(float3 color, float hue)
{
	hue /= 100;

	float3 rethsl = RGBToHSL(color); //convert to HSL
	float3 hueColor = hue * (1 - color);
	rethsl.x -= hueColor.x; //Shift Hue
	rethsl.y += hueColor.y; //increase saturation
	rethsl.z -= hueColor.z; //decrease lightness, not too sure if this is all correct, with the multiplication following this...

	float3 result = HSLToRGB(rethsl);
	return result;
}

float3 saturationAdj(float3 diffuse, float saturation)
{
	float3 Out = 0.f;
	saturation /= 100;
	saturation += 1;
	float R = 0.3;
	float G = 0.59;
	float B = 0.11;
	float DivideByOne = ((diffuse.x * R) + (diffuse.y * G)) + (diffuse.z * B);
	float3 OutGrey = float3(DivideByOne, DivideByOne, DivideByOne);
	Out = float3(lerp(OutGrey, diffuse.xyz, saturation));
	return Out;
}

float3 brightcontrast(float3 diffuse, float bright, float contrast)
{
	bright /= 100;
	contrast /= 100;
	contrast += 1;
	if (contrast != 1 || bright != 0)
	{
		float3 result = (diffuse - 0.5) * contrast + 0.5 + bright;
		return result;
	}
	return diffuse;
}

float3 adjust(float3 diffuse, float4 colorValue)
{
	float3 result = diffuse;
	result = hueadj(result, colorValue.z);
	result = saturationAdj(result, colorValue.w);
	result = brightcontrast(result, colorValue.x, colorValue.y);
	return result;
}

float LightMultiply()
{
#ifdef ENABLE_CHARACTER_RENDER
	return g_psData.lightColor.w * g_psData.lightCharacterMultiply;
#else
	return g_psData.lightColor.w;
#endif
}

struct VS_OUT
{
	float4 position : POSITION;
	float4 diffuseTexCoord : TEXCOORD0;
	float4 posW : TEXCOORD1;
	float4 posWV : TEXCOORD2;

	float4 outDepth : TEXCOORD3;
	float2 variant : TEXCOORD4;	// x : 3dTo2d Value, z : fog Value
	float3 viewVec : TEXCOORD6;

	float3 normalW : NORMAL;
	float3 tangentW : TANGENT;
	float3 binormalW : BINORMAL;

#ifdef ENABLE_STATICSHADOWTEX
	float2 shadowTexCoord : TEXCOORD7;
#endif

#ifdef ENABLE_ENVTEX
	float2 envTexCoord : TEXCOORD8;
#endif
#ifdef ENABLE_INSTANCING
	uint InstanceID : TEXCOORD9;
#endif
};

struct VS_OUT_AURA
{
	float4 position : POSITION;
	float4 diffuseTexCoord : TEXCOORD0;
	float4 auraColor : TEXCOORD1;
};

struct PS_OUT2
{
	float4 albedo : COLOR0;
#ifdef ENABLE_DEPTH_MRT
	float4 depth : COLOR1;
#endif
};

#define VS_ModelOption_None 0
#define VS_ModelOption_Silhouette_Outline 1
#define VS_ModelOption_Outline 2
#define VS_ModelOption_SelectOutline 3

VS_OUT VS_ModelOption(in float4 inPos
	, in float3 inNormal
	, in float2 inTex0
	, in float2 inTex1
#ifdef ENABLE_SKINNING
	, in float4 inBlendWeight
	, in uint4 inBlendIndices
#endif
#ifdef ENABLE_INSTANCING
	, in uint InstanceID
#endif
	, uniform const uint ModelOption
)
{
	VS_OUT output = (VS_OUT)0;

	inPos.w = 1.f;

	float4 localPos = 0.f;
	float3 localNormal = 0.f;

#ifdef ENABLE_INSTANCING
	output.InstanceID = InstanceID;
	ModelInstanceData instdata = g_modelInstanceData[InstanceID];
#else
	ModelInstanceData instdata = g_modelInstanceData;
#endif

#ifdef ENABLE_SKINNING
	inBlendWeight.w = 1.f - (inBlendWeight.x + inBlendWeight.y + inBlendWeight.z);
	ComputeSkinning(inPos, inNormal, inBlendWeight, inBlendIndices, instdata.renderData.vtfID, localPos, localNormal);
#else
	localPos = inPos;
	localNormal = inNormal;
#endif

	localNormal = normalize(localNormal);
	if (ModelOption == VS_ModelOption_Silhouette_Outline)
	{
		localPos.xyz += localNormal.xyz * 0.8f;
	}
	else if (ModelOption == VS_ModelOption_Outline)
	{
		localPos.xyz += localNormal.xyz * 0.4f;
	}
	else if (ModelOption == VS_ModelOption_SelectOutline)
	{
		localPos.xyz += localNormal.xyz * 1.f;
	}

	localPos.w = 1.f;

	float4x4 worldMatrix = DecodeMatrix(instdata.worldTransformData);
	float4 posW = mul(localPos, worldMatrix);

#ifdef ENABLE_WATER_NEW
	posW.y += g_waterData.maxLevel * g_psData.groundWetness;
#endif

	float3x3 worldMat3 = (float3x3)worldMatrix;
	float3 randomUnit = {-0.67203569f, 0.18413987f, -0.71725904f};
	output.normalW = mul(localNormal, worldMat3);
	output.tangentW = mul(cross(localNormal, randomUnit), worldMat3);
	output.binormalW = mul(cross(localNormal, output.tangentW), worldMat3);

	// 캐릭터 2D로 찍기
#ifdef ENABLE_2D
#ifdef ENABLE_INSTANCING
	Render2DData render2DData = g_render2DData[InstanceID];
#else
	Render2DData render2DData = g_render2DData;
#endif
	float4x4 billboardMatrix = DecodeMatrix(render2DData.billBoardTransformData);
	float4x4 charViewProjMatrix = DecodeMatrix(render2DData.charViewProjTransformData);
	output.position = CalcWVP(posW, g_vsData.viewMatrix, g_vsData.viewProjMatrix, charViewProjMatrix, billboardMatrix, render2DData.pivot, output.posWV);
#else
	output.position = CalcWVP(posW, g_vsData.viewMatrix, g_vsData.viewProjMatrix, output.posWV);
#endif

#ifdef ENABLE_CHARACTER_RENDER
	float4x4 worldAngleMatrix = mul(worldMatrix, g_vsData.angleMatrix);
	output.variant.x = mul(localPos + float4(0.f, -25.5f, 0.f, 0.f), worldAngleMatrix).z * 0.1f;
#endif

	output.posW = posW;

#ifdef ENABLE_DIFFUSETEX
#ifdef ENABLE_DIFFUSETEX_ANIMATION
	float4x4 uvAnimationMatrix = DecodeMatrix(instdata.renderData.uvAnimationTransformData);
	SetDiffuseTexCoord(inTex0, uvAnimationMatrix, output.diffuseTexCoord);
#else
	SetDiffuseTexCoord(inTex0, output.diffuseTexCoord);
#endif
#endif

#ifdef ENABLE_GRASS
	float delta = 0.0001f;
	delta = saturate(delta) * g_grassData.windPower/* * 10.f*/;
	delta = sin((instdata.renderData.timeStamp) * g_grassData.time + g_grassData.timeOffset + output.posW.x * 0.1 - output.posW.z * 0.1) * delta + g_grassData.windDir * delta;

	output.position.x += delta;
	output.position.y -= delta * delta * 0.05f;
#endif

#ifdef ENABLE_ENVTEX
	float4x4 worldViewMatrix = mul(worldMatrix, g_vsData.viewMatrix);
	float3 normalWV = normalize(mul(localNormal, (float3x3)worldViewMatrix));
	output.envTexCoord.xy = reflect(output.posWV.xyz, normalWV).xy;
#endif

#ifdef ENABLE_STATICSHADOWTEX
	output.shadowTexCoord.xy = inTex1.xy;
#endif

	output.variant.y = saturate(GetFogValue(g_vsData.fogDist, output.position.w));
	output.viewVec = g_vsData.invViewMatrix[3].xyz - output.posW.xyz;

#ifdef ENABLE_CHARACTER_RENDER
	// 얼굴 그리는 부분
#if defined(ENABLE_DIFFUSETEX) && defined(ENABLE_FACE)
	float4 faceUV = instdata.renderData.faceUV;
	output.diffuseTexCoord.x = faceUV.x * output.diffuseTexCoord.x + faceUV.z;
	output.diffuseTexCoord.y = faceUV.y * output.diffuseTexCoord.y + faceUV.w;
#endif
#endif

#ifdef ENABLE_WATER
	output.outDepth = output.position;
#else
	output.outDepth = output.position / output.position.w;
	output.outDepth.w = output.position.z;
#endif

	return output;
}

VS_OUT VS_Model(in float4 inPos : POSITION
	, in float3 inNormal : NORMAL
	, in float2 inTex0 : TEXCOORD0
	, in float2 inTex1 : TEXCOORD1
#ifdef ENABLE_SKINNING
	, in float4 inBlendWeight : BLENDWEIGHT
	, in uint4 inBlendIndices : BLENDINDICES
#endif
#ifdef ENABLE_INSTANCING
	, in uint InstanceID : SV_InstanceID
#endif
)
{
#ifdef ENABLE_SKINNING
#ifdef ENABLE_INSTANCING
	return VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, InstanceID, VS_ModelOption_None);
#else
	return VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, VS_ModelOption_None);
#endif
#else
#ifdef ENABLE_INSTANCING
	return VS_ModelOption(inPos, inNormal, inTex0, inTex1, InstanceID, VS_ModelOption_None);
#else
	return VS_ModelOption(inPos, inNormal, inTex0, inTex1, VS_ModelOption_None);
#endif
#endif
}

VS_OUT VS_Model_Outline(in float4 inPos : POSITION
	, in float3 inNormal : NORMAL
	, in float2 inTex0 : TEXCOORD0
	, in float2 inTex1 : TEXCOORD1
#ifdef ENABLE_SKINNING
	, in float4 inBlendWeight : BLENDWEIGHT
	, in uint4 inBlendIndices : BLENDINDICES
#endif
#ifdef ENABLE_INSTANCING
	, in uint InstanceID : SV_InstanceID
#endif
)
{
#ifdef ENABLE_SKINNING
#ifdef ENABLE_INSTANCING
	return VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, InstanceID, VS_ModelOption_Outline);
#else
	return VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, VS_ModelOption_Outline);
#endif
#else
#ifdef ENABLE_INSTANCING
	return VS_ModelOption(inPos, inNormal, inTex0, inTex1, InstanceID, VS_ModelOption_Outline);
#else
	return VS_ModelOption(inPos, inNormal, inTex0, inTex1, VS_ModelOption_Outline);
#endif
#endif
}

VS_OUT VS_Model_Head_Outline1(in float4 inPos : POSITION
	, in float3 inNormal : NORMAL
	, in float2 inTex0 : TEXCOORD0
	, in float2 inTex1 : TEXCOORD1
#ifdef ENABLE_SKINNING
	, in float4 inBlendWeight : BLENDWEIGHT
	, in uint4 inBlendIndices : BLENDINDICES
#endif
#ifdef ENABLE_INSTANCING
	, in uint InstanceID : SV_InstanceID
#endif
)
{
	VS_OUT output = (VS_OUT)0;
#ifdef ENABLE_SKINNING
#ifdef ENABLE_INSTANCING
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, InstanceID, VS_ModelOption_None);
#else
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, VS_ModelOption_None);
#endif
#else
#ifdef ENABLE_INSTANCING
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, InstanceID, VS_ModelOption_None);
#else
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, VS_ModelOption_None);
#endif
#endif

	output.position.x -= 1.0f;
	output.position.z += 0.1f;
	return output;
}

VS_OUT VS_Model_Head_Outline2(in float4 inPos : POSITION
	, in float3 inNormal : NORMAL
	, in float2 inTex0 : TEXCOORD0
	, in float2 inTex1 : TEXCOORD1
#ifdef ENABLE_SKINNING
	, in float4 inBlendWeight : BLENDWEIGHT
	, in uint4 inBlendIndices : BLENDINDICES
#endif
#ifdef ENABLE_INSTANCING
	, in uint InstanceID : SV_InstanceID
#endif
)
{
	VS_OUT output = (VS_OUT)0;
#ifdef ENABLE_SKINNING
#ifdef ENABLE_INSTANCING
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, InstanceID, VS_ModelOption_None);
#else
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, VS_ModelOption_None);
#endif
#else
#ifdef ENABLE_INSTANCING
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, InstanceID, VS_ModelOption_None);
#else
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, VS_ModelOption_None);
#endif
#endif

	output.position.x += 1.0f;
	output.position.z += 0.1f;
	return output;
}

VS_OUT VS_Model_Head_Outline3(in float4 inPos : POSITION
	, in float3 inNormal : NORMAL
	, in float2 inTex0 : TEXCOORD0
	, in float2 inTex1 : TEXCOORD1
#ifdef ENABLE_SKINNING
	, in float4 inBlendWeight : BLENDWEIGHT
	, in uint4 inBlendIndices : BLENDINDICES
#endif
#ifdef ENABLE_INSTANCING
	, in uint InstanceID : SV_InstanceID
#endif
)
{
	VS_OUT output = (VS_OUT)0;
#ifdef ENABLE_SKINNING
#ifdef ENABLE_INSTANCING
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, InstanceID, VS_ModelOption_None);
#else
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, VS_ModelOption_None);
#endif
#else
#ifdef ENABLE_INSTANCING
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, InstanceID, VS_ModelOption_None);
#else
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, VS_ModelOption_None);
#endif
#endif

	output.position.y -= 1.0f;
	output.position.z += 0.1f;
	return output;
}

VS_OUT VS_Model_Head_Outline4(in float4 inPos : POSITION
	, in float3 inNormal : NORMAL
	, in float2 inTex0 : TEXCOORD0
	, in float2 inTex1 : TEXCOORD1
#ifdef ENABLE_SKINNING
	, in float4 inBlendWeight : BLENDWEIGHT
	, in uint4 inBlendIndices : BLENDINDICES
#endif
#ifdef ENABLE_INSTANCING
	, in uint InstanceID : SV_InstanceID
#endif
)
{
	VS_OUT output = (VS_OUT)0;
#ifdef ENABLE_SKINNING
#ifdef ENABLE_INSTANCING
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, InstanceID, VS_ModelOption_None);
#else
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, VS_ModelOption_None);
#endif
#else
#ifdef ENABLE_INSTANCING
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, InstanceID, VS_ModelOption_None);
#else
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, VS_ModelOption_None);
#endif
#endif

	output.position.y += 1.0f;
	output.position.z += 0.1f;
	return output;
}

VS_OUT VS_Model_Select_Outline(in float4 inPos : POSITION
	, in float3 inNormal : NORMAL
	, in float2 inTex0 : TEXCOORD0
	, in float2 inTex1 : TEXCOORD1
#ifdef ENABLE_SKINNING
	, in float4 inBlendWeight : BLENDWEIGHT
	, in uint4 inBlendIndices : BLENDINDICES
#endif
#ifdef ENABLE_INSTANCING
	, in uint InstanceID : SV_InstanceID
#endif
)
{
#ifdef ENABLE_SKINNING
#ifdef ENABLE_INSTANCING
	return VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, InstanceID, VS_ModelOption_SelectOutline);
#else
	return VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, VS_ModelOption_SelectOutline);
#endif
#else
#ifdef ENABLE_INSTANCING
	return VS_ModelOption(inPos, inNormal, inTex0, inTex1, InstanceID, VS_ModelOption_SelectOutline);
#else
	return VS_ModelOption(inPos, inNormal, inTex0, inTex1, VS_ModelOption_SelectOutline);
#endif
#endif
}

VS_OUT VS_Model_Silhouette_Outline(in float4 inPos : POSITION
	, in float3 inNormal : NORMAL
	, in float2 inTex0 : TEXCOORD0
	, in float2 inTex1 : TEXCOORD1
#ifdef ENABLE_SKINNING
	, in float4 inBlendWeight : BLENDWEIGHT
	, in uint4 inBlendIndices : BLENDINDICES
#endif
#ifdef ENABLE_INSTANCING
	, in uint InstanceID : SV_InstanceID
#endif
)
{
	VS_OUT output = (VS_OUT)0;
#ifdef ENABLE_SKINNING
#ifdef ENABLE_INSTANCING
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, InstanceID, VS_ModelOption_Silhouette_Outline);
#else
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, VS_ModelOption_Silhouette_Outline);
#endif
#else
#ifdef ENABLE_INSTANCING
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, InstanceID, VS_ModelOption_Silhouette_Outline);
#else
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, VS_ModelOption_Silhouette_Outline);
#endif
#endif

	output.position.z += 0.01f;
	return output;
}

VS_OUT VS_Model_Silhouette_Head_Outline1(in float4 inPos : POSITION
	, in float3 inNormal : NORMAL
	, in float2 inTex0 : TEXCOORD0
	, in float2 inTex1 : TEXCOORD1
#ifdef ENABLE_SKINNING
	, in float4 inBlendWeight : BLENDWEIGHT
	, in uint4 inBlendIndices : BLENDINDICES
#endif
#ifdef ENABLE_INSTANCING
	, in uint InstanceID : SV_InstanceID
#endif
)
{
	VS_OUT output = (VS_OUT)0;
#ifdef ENABLE_SKINNING
#ifdef ENABLE_INSTANCING
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, InstanceID, VS_ModelOption_None);
#else
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, VS_ModelOption_None);
#endif
#else
#ifdef ENABLE_INSTANCING
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, InstanceID, VS_ModelOption_None);
#else
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, VS_ModelOption_None);
#endif
#endif

	output.position.x -= 0.8f;
	output.position.z += 0.01f;
	return output;
}

VS_OUT VS_Model_Silhouette_Head_Outline2(in float4 inPos : POSITION
	, in float3 inNormal : NORMAL
	, in float2 inTex0 : TEXCOORD0
	, in float2 inTex1 : TEXCOORD1
#ifdef ENABLE_SKINNING
	, in float4 inBlendWeight : BLENDWEIGHT
	, in uint4 inBlendIndices : BLENDINDICES
#endif
#ifdef ENABLE_INSTANCING
	, in uint InstanceID : SV_InstanceID
#endif
)
{
	VS_OUT output = (VS_OUT)0;
#ifdef ENABLE_SKINNING
#ifdef ENABLE_INSTANCING
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, InstanceID, VS_ModelOption_None);
#else
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, VS_ModelOption_None);
#endif
#else
#ifdef ENABLE_INSTANCING
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, InstanceID, VS_ModelOption_None);
#else
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, VS_ModelOption_None);
#endif
#endif

	output.position.x += 0.8f;
	output.position.z += 0.01f;
	return output;
}

VS_OUT VS_Model_Silhouette_Head_Outline3(in float4 inPos : POSITION
	, in float3 inNormal : NORMAL
	, in float2 inTex0 : TEXCOORD0
	, in float2 inTex1 : TEXCOORD1
#ifdef ENABLE_SKINNING
	, in float4 inBlendWeight : BLENDWEIGHT
	, in uint4 inBlendIndices : BLENDINDICES
#endif
#ifdef ENABLE_INSTANCING
	, in uint InstanceID : SV_InstanceID
#endif
)
{
	VS_OUT output = (VS_OUT)0;
#ifdef ENABLE_SKINNING
#ifdef ENABLE_INSTANCING
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, InstanceID, VS_ModelOption_None);
#else
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, VS_ModelOption_None);
#endif
#else
#ifdef ENABLE_INSTANCING
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, InstanceID, VS_ModelOption_None);
#else
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, VS_ModelOption_None);
#endif
#endif

	output.position.y -= 0.8f;
	output.position.z += 0.01f;
	return output;
}

VS_OUT VS_Model_Silhouette_Head_Outline4(in float4 inPos : POSITION
	, in float3 inNormal : NORMAL
	, in float2 inTex0 : TEXCOORD0
	, in float2 inTex1 : TEXCOORD1
#ifdef ENABLE_SKINNING
	, in float4 inBlendWeight : BLENDWEIGHT
	, in uint4 inBlendIndices : BLENDINDICES
#endif
#ifdef ENABLE_INSTANCING
	, in uint InstanceID : SV_InstanceID
#endif
)
{
	VS_OUT output = (VS_OUT)0;
#ifdef ENABLE_SKINNING
#ifdef ENABLE_INSTANCING
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, InstanceID, VS_ModelOption_None);
#else
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, inBlendWeight, inBlendIndices, VS_ModelOption_None);
#endif
#else
#ifdef ENABLE_INSTANCING
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, InstanceID, VS_ModelOption_None);
#else
	output = VS_ModelOption(inPos, inNormal, inTex0, inTex1, VS_ModelOption_None);
#endif
#endif

	output.position.y += 0.8f;
	output.position.z += 0.01f;
	return output;
}

VS_OUT_AURA VS_ModelAura(in float4 inPos : POSITION
	, in float3 inNormal : NORMAL
	, in float2 inTex0 : TEXCOORD0
	, in float2 inTex1 : TEXCOORD1
#ifdef ENABLE_SKINNING
	, in float4 inBlendWeight : BLENDWEIGHT
	, in uint4 inBlendIndices : BLENDINDICES
#endif
#ifdef ENABLE_INSTANCING
	, in uint InstanceID : SV_InstanceID
#endif
)
{
	VS_OUT_AURA output = (VS_OUT_AURA)0;

	inPos.w = 1.f;

	float4 localPos = 0.f;
	float3 localNormal = 0.f;

#ifdef ENABLE_INSTANCING
	ModelInstanceData modelInstanceData = g_modelInstanceData[InstanceID];
#else
	ModelInstanceData modelInstanceData = g_modelInstanceData;
#endif

	float4x4 worldMatrix = DecodeMatrix(modelInstanceData.worldTransformData);

#ifdef ENABLE_SKINNING
	inBlendWeight.w = 1.f - (inBlendWeight.x + inBlendWeight.y + inBlendWeight.z);
	ComputeSkinning(inPos, inNormal, inBlendWeight, inBlendIndices, modelInstanceData.renderData.vtfID, localPos, localNormal);
#else
	localPos = inPos;
	localNormal = inNormal;
#endif

	localPos.w = 1.f;
	localNormal = normalize(localNormal);

	float4 posW = mul(localPos, worldMatrix);
	float4 posWV = 0.f;

#ifdef ENABLE_2D
#ifdef ENABLE_INSTANCING
	Render2DData render2DData = g_render2DData[InstanceID];
#else
	Render2DData render2DData = g_render2DData;
#endif
	float4x4 billboardMatrix = DecodeMatrix(render2DData.billBoardTransformData);
	float4x4 charViewProjMatrix = DecodeMatrix(render2DData.charViewProjTransformData);
	output.position = CalcWVP(posW, g_vsData.viewMatrix, g_vsData.viewProjMatrix, charViewProjMatrix, billboardMatrix, render2DData.pivot, posWV);
#else
	output.position = CalcWVP(posW, g_vsData.viewMatrix, g_vsData.viewProjMatrix, posWV);
#endif

#ifdef ENABLE_DIFFUSETEX
#ifdef ENABLE_DIFFUSETEX_ANIMATION
	float4x4 uvAnimationMatrix = DecodeMatrix(modelInstanceData.renderData.uvAnimationTransformData);
	SetDiffuseTexCoord(inTex0, uvAnimationMatrix, output.diffuseTexCoord);
#else
	SetDiffuseTexCoord(inTex0, output.diffuseTexCoord);
#endif
#endif

#if defined(ENABLE_CHARACTER_RENDER) && defined(ENABLE_DIFFUSETEX) && defined(ENABLE_FACE)
	float4 faceUV = modelInstanceData.renderData.faceUV;
	output.diffuseTexCoord.x = faceUV.x * output.diffuseTexCoord.x + faceUV.z;
	output.diffuseTexCoord.y = faceUV.y * output.diffuseTexCoord.y + faceUV.w;
#endif

	float auraFactor = modelInstanceData.renderData.auraValue.x;
	float auraTime = modelInstanceData.renderData.auraValue.y;

	float y = output.position.y;
	float3 worldNormal = mul(localNormal.xyz, (float3x3)worldMatrix);
	float3 vpNormal = mul(worldNormal.xyz, (float3x3)g_vsData.viewProjMatrix);

#if defined(ENABLE_CHARACTER_RENDER) && defined(ENABLE_DIFFUSETEX) && defined(ENABLE_FACE)
#else
	float scale = max(1.1f, g_vsData.cameraDistance / 161.f);
	output.position.xy += vpNormal.xy * scale;
#endif

	output.position.x += auraTime * vpNormal.x * auraFactor + sin(auraTime * 3.14f) * 0.5f;
	output.position.y += auraTime * vpNormal.y * auraFactor * 1.5f;
	output.position.y = max(output.position.y, y + sin(auraTime));
#if defined(ENABLE_ITEM_AURA)
	float auraFactorOffset = modelInstanceData.renderData.auraValue.z;
	output.position.z += auraTime * vpNormal.z * ((auraFactor * 0.1f) + auraFactorOffset);
#else
	output.position.z += 0.2f;
#endif

	output.auraColor = modelInstanceData.renderData.auraColor;

	return output;
}

#ifdef ENABLE_HEIGHT
VS_OUT VS_Height(in float4 inPos : POSITION
	, in float3 inNormal : NORMAL
	, in float2 inTex0 : TEXCOORD0
	, in float2 inTex1 : TEXCOORD1
#ifdef ENABLE_SKINNING
	, in float4 inBlendWeight : BLENDWEIGHT
	, in uint4 inBlendIndices : BLENDINDICES
#endif
#ifdef ENABLE_INSTANCING
	, in uint InstanceID : SV_InstanceID
#endif
)
{
	VS_OUT output = (VS_OUT)0;

	inPos.w = 1.f;

	float4 localPos = 0.f;
	float3 localNormal = 0.f;

#ifdef ENABLE_INSTANCING
	output.InstanceID = InstanceID;
	ModelInstanceData modelInstanceData = g_modelInstanceData[InstanceID];
#else
	ModelInstanceData modelInstanceData = g_modelInstanceData;
#endif

	float4x4 worldMatrix = DecodeMatrix(modelInstanceData.worldTransformData);

#ifdef ENABLE_SKINNING
	inBlendWeight.w = 1.f - (inBlendWeight.x + inBlendWeight.y + inBlendWeight.z);
	ComputeSkinning(inPos, inNormal, inBlendWeight, inBlendIndices, modelInstanceData.renderData.vtfID, localPos, localNormal);
#else
	localPos = inPos;
	localNormal = inNormal;
#endif

	localPos.xyz += normalize(localNormal) * 0.5f;
	localPos.w = 1.f;

	float3 posW = mul(localPos, worldMatrix).xyz;
	float worldY = -(posW.y + g_heightMapData.bottom) / (g_heightMapData.top - g_heightMapData.bottom);
	output.position = float4(posW, 1);
	output.position.y = output.position.z;
	output.position.z = worldY;
	output.position.x += g_heightMapData.offsetX;
	output.position.y += g_heightMapData.offsetY;
	output.position.xy /= g_heightMapData.size;

	output.outDepth.w = output.position.z;

	return output;
}
#endif

void TexSky(out float3 sky, out float3 sun, float3 dir, float sunGloss)
{
	float2 uv = dir.xz / pow(abs(dir.y), 0.25) + g_psData.windUvOffset;
	float noise = TexPerlinNoise(uv);
	float cloud = lerp(0.6, 0.28, g_psData.cloudAmount);
	float cloudMap = smoothstep(cloud, cloud + 0.05, noise);
	float cloudShadow = smoothstep(cloud, lerp(1, 0.7, g_psData.cloudAmount), noise);
	float3 skycol = float3(0.5, 0.75, 0.95);
	sky = lerp(skycol, (float3)0.99, cloudMap);
	sky = lerp(sky, skycol * lerp(0.6, 0.3, pow(g_psData.cloudAmount, 2)), cloudShadow);
	sky = lerp((float3)0.1, sky, step(0, dir.y));
	sun = float3(1.0, 0.9, 0.9);
	sun *= pow(saturate(dot(g_psData.lightDir, -dir)), lerp(10, lerp(5000, 1000, cloudMap), pow(sunGloss, 2)));
	sun *= lerp(1, 0.3, cloudMap);
	sun *= 1 - cloudShadow;
}

float3 Reflect(VS_OUT input, float3 diffuse, float3 normalT, float gloss, float fresnelExp = 2, float rimMin = 0.1, float rimMax = 0.9, bool additive = false)
{
#ifdef LOW_QUALITY
	return diffuse;
#else
	float3x3 TBN = float3x3(input.tangentW, input.binormalW, input.normalW);
	float3 normalW = normalize(mul(normalT, TBN)).zyx;
	float3 viewDir = normalize(input.viewVec);

	float3 r = reflect(-viewDir, normalW);
	float3 sky, sun;
	TexSky(sky, sun, r, gloss);
	
	float rim = lerp(rimMin, rimMax, pow(1 - saturate(dot(normalW, viewDir)), fresnelExp));
	float shadow = 1;

#ifdef ENABLE_STATICSHADOWTEX
	float3 shadowMap = saturate(TexStaticShadow(input.shadowTexCoord.xy).rgb);
	shadow = (shadowMap.r + shadowMap.g + shadowMap.b) / 3;
	shadow = smoothstep(0.4, 0.5, shadow);
#endif

	float brightness = saturate(dot(normalW, -g_psData.lightDir)) / clamp(dot(input.normalW, -g_psData.lightDir), 0.6, 1);
	return additive
		? diffuse * brightness + (sky * rim + sun * shadow) * gloss
		: lerp(diffuse, sky, gloss * rim) * brightness + sun * shadow * gloss;
#endif
}

#ifdef ENABLE_DEPTH_RENDER
float4 PS_Depth(VS_OUT input) : COLOR0
{
	float4 output = 0.f;

	output.rgb = input.outDepth.w;

	float alpha = 0.f;
#ifdef ENABLE_DIFFUSETEX
	float4 diffuseColor = TexDiffuse(input.diffuseTexCoord.xy);
	alpha = diffuseColor.a;
#endif

	output.a = alpha;
	output.r = (input.outDepth.w);
	output.g = length(input.posWV.xyz);
	output.b = (input.posW.y + 300) * 0.001;
	return output;
}
#else

float3 BlendAngleCorrectedNormals(float3 base, float3 additional)
{
	base.z += 1; additional.xy *= -1;
	return normalize(base * dot(base, additional) - additional * base.z);
}

float3 CombineFourNormals(float3 n1, float3 n2, float3 n3, float3 n4, float4 weights)
{
	float4 v = lerp(1, float4(n1.z, n2.z, n3.z, n4.z), weights);
	float z = v.x * v.y * v.z * v.w;
	float2 xy = n1.xy * weights.x + n2.xy * weights.y + n3.xy * weights.z + n4.xy * weights.w;
	return normalize(float3(xy, z));
}

float3 RainRipple(float2 uv, float time, float weight, float height)
{
	float4 texRipple = TexRainRipples(uv);
	texRipple.rgb = texRipple.rgb * 2 - 1;
	float t = frac(time + texRipple.a);
	float mask = sin(clamp((texRipple.r + t - 1) * 12, 0, 4) * 3.14159265);
	mask *= saturate(weight * 0.8 + 0.2 - t);
	return float3(texRipple.gb * mask * height, 1);
}

float3 RainRipples(float2 uv, float time, float height = 0.03)
{
	static const float intensity = saturate(lerp(0.5, 1, g_psData.rainfallAmount));
	float4 times = (float4)time * float4(0.93, 1.1, 0.85, 1) + float4(0, 0.2, 0.45, 0.7);
	float4 weights = saturate(((float4)intensity - float4(0, 0.25, 0.5, 0.75)) * 4);
	float4 heights = height * float4(0.93, 1.1, 0.85, 1);
	float3 r1 = RainRipple(uv * 0.7, times.x, weights.x, heights.x);
	float3 r2 = RainRipple((uv + float2(-0.55, 0.3)) * 0.75, times.y, weights.y, heights.y);
	float3 r3 = RainRipple((uv + float2(0.6, 0.85)) * 0.65, times.z, weights.z, heights.z);
	float3 r4 = RainRipple((uv + float2(0.5, -0.75)) * 0.72, times.w, weights.w, heights.w);
	return CombineFourNormals(r1, r2, r3, r4, weights);
}

float3 WaterNormal(float2 uv, float2 offset)
{
	uv += g_psData.windUvOffset;
	return normalize(TexWaterNormal(uv + offset) + TexWaterNormal(uv*0.9 - offset*0.9) - 1);
}

#ifdef ENABLE_WATER
float4 PS_Water(VS_OUT input) : COLOR0
{
#ifdef ENABLE_WATER_NEW

#ifdef LOW_QUALITY
	return g_waterData.color;

#else // LOW_QUALITY

	ModelInstanceData instdata = GetInstData(input);
	float time = instdata.renderData.timeStamp;

	// 일렁이는 표면
	float3 normalT = WaterNormal(input.posW.xz * g_waterData.uvScale, time * g_waterData.waveSpeed);
	float waveScale = g_waterData.waveScale * lerp(0.9, 1, g_psData.groundWetness) * lerp(0.9, 1, g_psData.windMagnitude);
	normalT = normalize(lerp(float3(0, 0, 1), normalT, waveScale));

	if (g_psData.rainfallAmount >= 0)
	{
		float3 ripples = RainRipples(input.posW.xz / 300, time * 0.8, 0.05);
		normalT = BlendAngleCorrectedNormals(normalT, ripples);
	}

	// 굴절
	input.outDepth.x /= input.outDepth.w;
	input.outDepth.y /= input.outDepth.w;
	float2 scrTexOut;
	scrTexOut.x = (input.outDepth.x + 1.f) * 0.5f;
	scrTexOut.y = (2.f - (input.outDepth.y + 1.f)) * 0.5f;
	scrTexOut.x += 0.0005f; // 스크린 오프셋 (매직넘버)
	scrTexOut.y += 0.0006f; // 스크린 오프셋 (매직넘버)
	float3 refraction = TexScreen(scrTexOut.xy + normalT.xy * g_waterData.refractionScale).rgb;
	float3 color = lerp(refraction, g_waterData.color.rgb, g_waterData.color.a);
	color = Reflect(input, color, normalT, 1, g_waterData.fresnelExp, g_waterData.rimMin, g_waterData.rimMax, true);
	return float4(color, 1);
#endif // LOW_QUALITY

#else // ENABLE_WATER_NEW

#ifdef LOW_QUALITY
	return TexDiffuse(input.diffuseTexCoord.xy);

#else // LOW_QUALITY
	float4 output = 0.f;

	input.outDepth.x /= input.outDepth.w;
	input.outDepth.y /= input.outDepth.w;

	float2 scrTexOut;
	scrTexOut.x = (input.outDepth.x + 1.f) * 0.5f;
	scrTexOut.y = (2.f - (input.outDepth.y + 1.f)) * 0.5f;

	// 스크린 오프셋 (매직넘버)
	scrTexOut.x += 0.0005f;
	scrTexOut.y += 0.0006f;

#ifdef ENABLE_INSTANCING
	ModelInstanceData modelInstanceData = g_modelInstanceData[input.InstanceID];
#else
	ModelInstanceData modelInstanceData = g_modelInstanceData;
#endif

#ifdef ENABLE_DIFFUSETEX
	// sway
	float dt = sin(modelInstanceData.renderData.timeStamp * g_waterData.swaySpeed + input.posW.x * g_waterData.swayRange.x) * g_waterData.swayPower;
	input.diffuseTexCoord.xy += normalize(g_waterData.swayRange) * dt;

	// speed
	input.diffuseTexCoord.xy += modelInstanceData.renderData.timeStamp * g_waterData.diffDir;
	output = TexDiffuse(input.diffuseTexCoord.xy);
#endif

#ifdef ENABLE_STATICSHADOWTEX
	float4 shadowColor = TexStaticShadow(input.shadowTexCoord.xy);
	output.rgb *= shadowColor.rgb * 2.f * g_psData.lightColor.rgb * pow(max(LightMultiply(), 0.01f), 1.5f);
#endif

	// refraction
	float2 uv = input.posW.xz * g_waterData.refractionNormalSize;
	uv += modelInstanceData.renderData.timeStamp * g_waterData.refractionDir;
	float4 normal = TexWaterNormal(uv) - 0.5f;

	output.rgb = TexScreen(scrTexOut.xy + normal.xy * g_waterData.refractionPower).rgb * ((float3)1.f - output.aaa) + output.rgb * output.a;
	output.a = 1.f;

	// spray
	uv = input.posW.xz * g_waterData.sprayNormalSize;
	uv += modelInstanceData.renderData.timeStamp * g_waterData.sprayDir;
	normal = TexWaterNormal(uv) - 0.5f;

	scrTexOut.xy += normal.xy * g_waterData.sprayPower;

	float edge1 = input.posW.y - TexWaterDepth(scrTexOut.xy).b * 1000.f + 300.f;
	edge1 *= g_waterData.sprayRange;

	edge1 = step(edge1, 1.f) * edge1;
	edge1 = step(0.f, edge1) * edge1;
	edge1 = 1 - edge1 - step(1.f, 1.f - edge1);
	output.rgb += edge1 * edge1 * g_waterData.sprayColor;

	if (g_psData.fogColor.w > 0)
	{
		output.rgb = lerp(g_psData.fogColor.rgb, output.rgb, 1.f - ((1.f - input.variant.y) * 0.3f));
	}

	output.rgb *= g_psData.lightColor.rgb * LightMultiply();

	saturate(output.rgb);

	return output;
#endif // LOW_QUALITY
#endif // ENABLE_WATER_NEW
}
#endif

float TexNoise(float2 uv, float pivot, float transition)
{
	float a = pivot - transition, b = pivot + transition;
	return smoothstep(a, b, TexPerlinNoise(uv));
}

float4 TexPuddle(float2 uv, float pivot, float transition)
{
	float height = smoothstep(pivot - transition, pivot + transition, TexPerlinNoise(uv));
	float L = smoothstep(pivot - transition, pivot + transition, TexPerlinNoiseOffset(uv, int2(-1, 0)));
	float R = smoothstep(pivot - transition, pivot + transition, TexPerlinNoiseOffset(uv, int2(1, 0)));
	float T = smoothstep(pivot - transition, pivot + transition, TexPerlinNoiseOffset(uv, int2(0, -1)));
	float B = smoothstep(pivot - transition, pivot + transition, TexPerlinNoiseOffset(uv, int2(0, 1)));
	return float4(normalize(float3(R-L, B-T, 2)), height);
}

PS_OUT2 PS_Default(VS_OUT input)
{
	PS_OUT2 output = (PS_OUT2)0;
	ModelInstanceData instdata = GetInstData(input);
	float2 texCoord = input.diffuseTexCoord.xy;

#ifndef LOW_QUALITY
#ifdef ENABLE_PUDDLES
	float brightness = 1, puddle = 0, theta = 0;
	float3 normalT = float3(0, 0, 1);
	if (g_psData.groundWetness > 0.01)
	{
		float time = instdata.renderData.timeStamp;
		float4 puddleMap = TexPuddle(input.posW.xz / 200, lerp(0.8, 0.5, sqrt(saturate(g_psData.groundWetness))), 0.05);
		puddle = puddleMap.w;
		normalT = puddleMap.xyz;
		theta = smoothstep(0.99, 1, dot(float3(0, 1, 0), input.normalW)); // 경사진 곳에는 비가 고이지 않음
		brightness = lerp(1, lerp(0.9, 0.65, puddle), g_psData.groundWetness); // 물이 고인 부분은 살짝 어두워야 자연스러움

		float mask = smoothstep(0.99, 1, puddle) * theta;
		if (g_psData.windMagnitude > 0.01)
		{
			float3 waves = WaterNormal(input.posW.xz * 0.005, time * float2(0.015, 0));
			normalT = normalize(lerp(normalT, BlendAngleCorrectedNormals(normalT, waves), g_psData.windMagnitude * mask * 0.1));
		}

		if (g_psData.rainfallAmount >= 0 && g_psData.groundWetness > 0.5)
		{
			float3 ripples = RainRipples(input.posW.xz / 250, time * 0.9);
			normalT = lerp(normalT, BlendAngleCorrectedNormals(normalT, ripples), mask);
			normalT = normalize(normalT);
		}
		texCoord += normalT.xy * 0.2 * mask;
	}
#endif
#endif

#ifdef ENABLE_DIFFUSETEX
	output.albedo = TexDiffuse(texCoord);
#endif

	float snowmask = 0;
#ifndef NO_SNOW_PILE
	if (g_psData.groundSnowAmount > 0.01)
	{
		float snow = lerp(0.8, 0.3, pow(saturate(g_psData.groundSnowAmount), 0.8));
		snowmask = TexNoise(input.posW.xz / 300, snow, 0.1);
		snowmask *= smoothstep(0.5, 0.7, dot(float3(0, 1, 0), input.normalW)); // 경사진 곳에는 눈이 쌓이지 않음
		float3 snowtex = saturate(TexSnow(input.posW.xz / 100).rgb);
		output.albedo.rgb = lerp(output.albedo.rgb, pow((snowtex.r + snowtex.g + snowtex.b) / 3, 1.5) * 0.7, snowmask);
	}
#endif

#ifdef ENABLE_STATICSHADOWTEX
	float4 shadowColor = TexStaticShadow(input.shadowTexCoord.xy);
	output.albedo.rgb *= lerp(shadowColor.rgb, (shadowColor.r + shadowColor.g + shadowColor.b) / 3, snowmask * 0.8);
	output.albedo.rgb *= 2 * g_psData.lightColor.rgb * pow(max(LightMultiply(), 0.01f), 1.5f);
#else
	output.albedo.rgb *= g_psData.lightColor.rgb * LightMultiply();
#endif

	float4 blendColor = instdata.renderData.blendColor;
	float alphaBlending = instdata.renderData.alphaBlending;

	output.albedo.rgb *= blendColor.rgb * 2.f;
	output.albedo.a *= blendColor.a;

#ifndef LOW_QUALITY
#ifdef ENABLE_PUDDLES
	if (g_psData.groundWetness > 0.01)
	{
		float3 reflected = Reflect(input, output.albedo.rgb * brightness, normalT, puddle*puddle, 2.5);
		output.albedo.rgb = lerp(output.albedo.rgb, reflected, theta);
	}
#endif
#endif

	if (g_psData.fogColor.w > 0)
		output.albedo.rgb = lerp(g_psData.fogColor.rgb, output.albedo.rgb, input.variant.y);

	output.albedo.a *= alphaBlending;

#ifdef ENABLE_DEPTH_MRT
	output.depth = CalcDepth(input.outDepth.w, input.posW.y, input.posWV);
#endif

	return output;
}

PS_OUT2 PS_Model(VS_OUT input)
{
	float4 diffuseColor = 1.f;
	float alpha = 0.f;

#ifdef ENABLE_DIFFUSETEX
	diffuseColor = TexDiffuse(input.diffuseTexCoord.xy);
	alpha = diffuseColor.a;
#endif

#ifdef ENABLE_SKIN_MASK_TEX
	float skinMask = TexDiffuseSkinMask(input.diffuseTexCoord.xy).r;
	if (skinMask > 0.f)
	{
#ifdef ENABLE_INSTANCING
		float4 skinBlendColor = g_modelInstanceData[input.InstanceID].renderData.skinBlendColor;
#else
		float4 skinBlendColor = g_modelInstanceData.renderData.skinBlendColor;
#endif

		const float4 pivotColor = float4(0.5f, 0.5f, 0.5f, 0.f);
		skinBlendColor = ((skinBlendColor - pivotColor) * skinMask) + 0.5f;
		diffuseColor.xyz = diffuseColor.xyz * skinBlendColor.xyz * 2.f;
	}
#endif

	PS_OUT2 output = (PS_OUT2)0;
	output.albedo = diffuseColor;

	float falloff = 0.f;

#ifdef ENABLE_CHARACTER_RENDER
	float3 normalizeNormal = normalize(input.normalW.xyz);

	falloff = FallOff(normalizeNormal, normalize(input.viewVec));
	float outlinevalue = smoothstep(0.f, 0.38f, falloff);
	float3 farColor = adjust(diffuseColor.rgb, g_characterData.farValue);
	float3 nearColor = diffuseColor.xyz;

	output.albedo.rgb = saturate(lerp(farColor, nearColor, saturate(input.variant.x * g_characterData.depthDistanceValue)));
#endif

	output.albedo.a = alpha;

#ifdef ENABLE_INSTANCING
	float4 blendColor = g_modelInstanceData[input.InstanceID].renderData.blendColor;
	float4 blendColorAdd = g_modelInstanceData[input.InstanceID].renderData.blendColorAdd;
#else
	float4 blendColor = g_modelInstanceData.renderData.blendColor;
	float4 blendColorAdd = g_modelInstanceData.renderData.blendColorAdd;
#endif

#ifdef ENABLE_LIGHT_MAP
	{
		float2 lightMapUV = 0.f;
		lightMapUV.x = clamp(((g_psData.lightMap_Length.x / 2.f + input.posW.x - g_psData.lightMap_Offset.x) / g_psData.lightMap_Length.x), 0.f, 1.f);
		lightMapUV.y = clamp(((g_psData.lightMap_Length.y / 2.f - input.posW.z + g_psData.lightMap_Offset.y) / g_psData.lightMap_Length.y), 0.f, 1.f);
		float4 lightColor = TexLightMap(lightMapUV);
		lightColor.rgb = pow(abs(lightColor.xyz), 1.f / 1.4f) + 0.2f;
		blendColor.rgb *= lightColor.rgb;
	}
#endif

	output.albedo.rgb *= blendColor.rgb * 2.f;
	output.albedo.rgb += blendColorAdd.rgb;

#ifdef ENABLE_CHARACTER_RENDER
	output.albedo.a *= blendColor.a;
#endif

	output.albedo = saturate(output.albedo);

#ifdef ENABLE_MATERIAL_CONFIG
	output.albedo = MaterialConfigColor(output.albedo, input.diffuseTexCoord.xy, falloff);
#endif

	if (g_psData.fogColor.w > 0)
	{
		output.albedo.rgb = lerp(g_psData.fogColor.rgb, output.albedo.rgb, 1 - ((1 - input.variant.y) * 0.3f));
	}

	output.albedo.rgb *= g_psData.lightColor.rgb * LightMultiply();

#ifdef ENABLE_DIFFUSETEX_ANIMATION
#ifdef ENABLE_INSTANCING
	uint useUvAnimMask = g_modelInstanceData[input.InstanceID].renderData.useUvAnimMask;
#else
	uint useUvAnimMask = g_modelInstanceData.renderData.useUvAnimMask;
#endif

	if (useUvAnimMask != 0)
	{
		float4 mask = TexUvAnimationMask(input.diffuseTexCoord.zw);
		output.albedo.a *= mask.r;
	}
#endif

#ifdef ENABLE_DEPTH_MRT
	output.depth = CalcDepth(input.outDepth.w, input.posW.y, input.posWV);
	output.depth.a = alpha;
#endif

	return output;
}

#define PS_ModelOption_Outline 1
#define PS_ModelOption_Select_Outline 2
float4 PS_ModelOption(VS_OUT input, uniform const uint PS_ModelOption)
{
	float4 diffuseColor = 1.f;
	float alpha = 0.f;

#ifdef ENABLE_DIFFUSETEX
	diffuseColor = TexDiffuse(input.diffuseTexCoord.xy);
	alpha = diffuseColor.a;
#endif

	float4 output = 0.f;
	output.rgb = diffuseColor.rgb;
	output.a = alpha;

	if (PS_ModelOption == PS_ModelOption_Select_Outline)
	{
#ifdef ENABLE_CHARACTER_RENDER
#ifdef ENABLE_INSTANCING
		float4 outlineColor = g_modelInstanceData[input.InstanceID].renderData.outlineColor;
		float4 blendColor = g_modelInstanceData[input.InstanceID].renderData.blendColor;
#else
		float4 outlineColor = g_modelInstanceData.renderData.outlineColor;
		float4 blendColor = g_modelInstanceData.renderData.blendColor;
#endif
		output.rgb = outlineColor.rgb;
		output.a = alpha * blendColor.a;
#endif
	}
	else
	{
#ifdef ENABLE_SKIN_MASK_TEX
		float skinMask = TexDiffuseSkinMask(input.diffuseTexCoord.xy).r;
		if (skinMask > 0.f)
		{
#ifdef ENABLE_INSTANCING
			float4 skinBlendColor = g_modelInstanceData[input.InstanceID].renderData.skinBlendColor;
#else
			float4 skinBlendColor = g_modelInstanceData.renderData.skinBlendColor;
#endif

			const float4 pivotColor = float4(0.5f, 0.5f, 0.5f, 0.f);
			skinBlendColor = ((skinBlendColor - pivotColor) * skinMask) + 0.5f;
			diffuseColor.xyz = diffuseColor.xyz * skinBlendColor.xyz * 2.f;
		}
#endif

		float falloff = 0.f;

#ifdef ENABLE_CHARACTER_RENDER
		float3 normalizeNormal = normalize(input.normalW.xyz);
		falloff = FallOff(normalizeNormal, normalize(input.viewVec));

		output = diffuseColor;
		output.rgb = saturate(output.rgb);
		output.a = alpha;
#endif

#ifdef ENABLE_INSTANCING
		float4 blendColor = g_modelInstanceData[input.InstanceID].renderData.blendColor;
#else
		float4 blendColor = g_modelInstanceData.renderData.blendColor;
#endif

		output.rgb *= blendColor.rgb * 2.f;
		output = saturate(output);
		output *= 0.5f;
		output.a = alpha;

#ifdef ENABLE_CHARACTER_RENDER
		output.a *= blendColor.a;
#endif

#ifdef ENABLE_MATERIAL_CONFIG
		output = MaterialConfigColor(output, input.diffuseTexCoord.xy, falloff);
		output.r *= 0.5f;
		output.g *= 0.5f;
		output.b *= 0.8f;
#endif
	}

	output.rgb *= g_psData.lightColor.rgb * LightMultiply();

#ifdef ENABLE_DIFFUSETEX_ANIMATION
#ifdef ENABLE_INSTANCING
	uint useUvAnimMask = g_modelInstanceData[input.InstanceID].renderData.useUvAnimMask;
#else
	uint useUvAnimMask = g_modelInstanceData.renderData.useUvAnimMask;
#endif

	if (useUvAnimMask != 0)
	{
		float4 mask = TexUvAnimationMask(input.diffuseTexCoord.zw);
		output.a *= mask.r;
	}
#endif

	return output;
}

float4 PS_Model_Outline(VS_OUT input) : COLOR0
{
	return PS_ModelOption(input, PS_ModelOption_Outline);
}

float4 PS_Model_Select_Outline(VS_OUT input) : COLOR0
{
	return PS_ModelOption(input, PS_ModelOption_Select_Outline);
}

PS_OUT2 PS_Model_Head(VS_OUT input)
{
	float4 diffuseColor = 1.f;
	float alpha = 0.f;

#ifdef ENABLE_DIFFUSETEX
	diffuseColor = TexDiffuse(input.diffuseTexCoord.xy);
	alpha = diffuseColor.a;
#endif

#ifdef ENABLE_SKIN_MASK_TEX
	float skinMask = TexDiffuseSkinMask(input.diffuseTexCoord.xy).r;
	if (skinMask > 0.f)
	{
#ifdef ENABLE_INSTANCING
		float4 skinBlendColor = g_modelInstanceData[input.InstanceID].renderData.skinBlendColor;
#else
		float4 skinBlendColor = g_modelInstanceData.renderData.skinBlendColor;
#endif

		const float4 pivotColor = float4(0.5f, 0.5f, 0.5f, 0.f);
		skinBlendColor = ((skinBlendColor - pivotColor) * skinMask) + 0.5f;
		diffuseColor.xyz = diffuseColor.xyz * skinBlendColor.xyz * 2.f;
	}
#endif

	PS_OUT2 output = (PS_OUT2)0;
	output.albedo = diffuseColor;

#ifdef ENABLE_CHARACTER_RENDER
	float3 normalizeNormal = normalize(input.normalW.xyz);

	float falloff = FallOff(normalizeNormal, normalize(input.viewVec));
	falloff = smoothstep(0.f, 0.38f, falloff);
	float3 farColor = adjust(diffuseColor.rgb, g_characterData.farValue);
	float3 nearColor = diffuseColor.xyz;

	output.albedo.rgb = saturate(lerp(farColor, nearColor, saturate(input.variant.x * g_characterData.depthDistanceValue)));
#endif

	output.albedo.a = alpha;

#ifdef ENABLE_INSTANCING
	float4 blendColor = g_modelInstanceData[input.InstanceID].renderData.blendColor;
	float4 blendColorAdd = g_modelInstanceData[input.InstanceID].renderData.blendColorAdd;
#else
	float4 blendColor = g_modelInstanceData.renderData.blendColor;
	float4 blendColorAdd = g_modelInstanceData.renderData.blendColorAdd;
#endif

#ifdef ENABLE_LIGHT_MAP
	{
		float2 lightMapUV = 0.f;
		lightMapUV.x = clamp(((g_psData.lightMap_Length.x / 2.f + input.posW.x - g_psData.lightMap_Offset.x) / g_psData.lightMap_Length.x), 0.f, 1.f);
		lightMapUV.y = clamp(((g_psData.lightMap_Length.y / 2.f - input.posW.z + g_psData.lightMap_Offset.y) / g_psData.lightMap_Length.y), 0.f, 1.f);
		float4 lightColor = TexLightMap(lightMapUV);
		lightColor.rgb = pow(abs(lightColor.xyz), 1.f / 1.4f) + 0.2f;
		blendColor.rgb *= lightColor.rgb;
	}
#endif

	output.albedo.rgb *= blendColor.rgb * 2.f;
	output.albedo.rgb += blendColorAdd.rgb;

#ifdef ENABLE_CHARACTER_RENDER
	output.albedo.a *= blendColor.a;
#endif

	output.albedo = saturate(output.albedo);

#ifdef ENABLE_MATERIAL_CONFIG
	output.albedo = MaterialConfigColorHead(output.albedo, 1.f);
#endif

	if (g_psData.fogColor.w > 0)
	{
		output.albedo.rgb = lerp(g_psData.fogColor.rgb, output.albedo.rgb, 1 - ((1 - input.variant.y) * 0.3f));
	}

	output.albedo.rgb *= g_psData.lightColor.rgb * LightMultiply();

#ifdef ENABLE_DEPTH_MRT
	output.depth = CalcDepth(input.outDepth.w, input.posW.y, input.posWV);
	output.depth.a = alpha;
#endif

	return output;
}

float4 PS_ModelAura(in VS_OUT_AURA input) : COLOR0
{
#ifdef ENABLE_DIFFUSETEX
	float4 diffTexColor = TexDiffuse(input.diffuseTexCoord.xy);
#endif

	float4 output = input.auraColor;
	output.rgb *= 2.f;
	return output;
}

#ifdef ENABLE_HEIGHT
float4 PS_Height(VS_OUT input) : COLOR0
{
	float4 output = 0.f;

	output.rgb = input.outDepth.w;
	float alpha = 1.f;
#ifdef ENABLE_DIFFUSETEX
	float4 diffTexColor = TexDiffuse(input.diffuseTexCoord.xy);
	alpha = diffTexColor.a;
#endif
	output.a = alpha;
	return output;
}
#endif

float4 PS_OutLineColor(VS_OUT input) : COLOR0
{
#ifdef ENABLE_INSTANCING
	float4 color = g_modelInstanceData[input.InstanceID].renderData.outlineColor;
#else
	float4 color = g_modelInstanceData.renderData.outlineColor;
#endif
	return color;
}
#endif

#ifdef ENABLE_CHARACTER_RENDER
float4 PS_Silhouette(VS_OUT input) : COLOR0
{
	float2 scrTexOut;
scrTexOut.x = (input.outDepth.x + 1.f) / 2;
scrTexOut.y = (2.f - (input.outDepth.y + 1.f)) / 2;

scrTexOut.x += 0.0005f;
scrTexOut.y += 0.0006f;

return float4(TexScreen(scrTexOut.xy).rgb * 0.5f, 1.f);
}

float4 PS_Silhouette_Outline(VS_OUT input) : COLOR0
{
	float2 scrTexOut;
scrTexOut.x = (input.outDepth.x + 1.f) / 2;
scrTexOut.y = (2.f - (input.outDepth.y + 1.f)) / 2;

scrTexOut.x += 0.0005f;
scrTexOut.y += 0.0006f;

return float4(lerp(TexScreen(scrTexOut.xy).rgb, 1.f, 0.3f), 1.f);
}

float4 PS_Silhouette_Head(VS_OUT input) : COLOR0
{
#ifdef ENABLE_DIFFUSETEX
	float alpha = TexDiffuse(input.diffuseTexCoord.xy).a;
#else
	float alpha = 1.f;
#endif

float2 scrTexOut;
scrTexOut.x = (input.outDepth.x + 1.f) / 2;
scrTexOut.y = (2.f - (input.outDepth.y + 1.f)) / 2;

scrTexOut.x += 0.0005f;
scrTexOut.y += 0.0006f;

return float4(TexScreen(scrTexOut.xy).rgb * 0.5f, alpha);
}

float4 PS_Silhouette_Head_Outline(VS_OUT input) : COLOR0
{
#ifdef ENABLE_DIFFUSETEX
	float alpha = TexDiffuse(input.diffuseTexCoord.xy).a;
#else
	float alpha = 1.f;
#endif

float2 scrTexOut;
scrTexOut.x = (input.outDepth.x + 1.f) / 2;
scrTexOut.y = (2.f - (input.outDepth.y + 1.f)) / 2;

scrTexOut.x += 0.0005f;
scrTexOut.y += 0.0006f;

return float4(lerp(TexScreen(scrTexOut.xy).rgb, 1.f, 0.3f), alpha);
}
#endif

// 렌더 스테이트 셋팅은 ModelRenderDX9.cpp 에서 해줌
#ifdef ENABLE_DEPTH_RENDER
technique DepthTech
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Model();
		PixelShader = compile ps_3_0 PS_Depth();
	}
};
#else
#ifdef ENABLE_WATER
technique WaterTech
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Model();
		PixelShader = compile ps_3_0 PS_Water();
	}
};
#endif

#ifdef ENABLE_HEIGHT
technique HeightTech
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Height();
		PixelShader = compile ps_3_0 PS_Height();
	}
};
#endif

technique Default_VertexTech
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Model();
		PixelShader = compile ps_3_0 PS_Default();
	}

	pass P1
	{
		VertexShader = compile vs_3_0 VS_Model();
		PixelShader = compile ps_3_0 PS_Default();
	}
};

technique Default_Vertex_AlphaTestTech
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Model();
		PixelShader = compile ps_3_0 PS_Default();
	}
};

technique Default_Vertex_AlphaTech
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Model();
		PixelShader = compile ps_3_0 PS_Default();
	}

	pass P1
	{
		VertexShader = compile vs_3_0 VS_Model();
		PixelShader = compile ps_3_0 PS_Default();
	}
};

#ifdef ENABLE_CHARACTER_RENDER
technique SilhouetteTech
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Model();
		PixelShader = compile ps_3_0 PS_Silhouette();
	}
};

technique Silhouette_OutlineTech
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Model_Silhouette_Outline();
		PixelShader = compile ps_3_0 PS_Silhouette_Outline();
	}
};

technique Silhouette_HeadTech
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Model();
		PixelShader = compile ps_3_0 PS_Silhouette_Head();
	}
};

technique Silhouette_Head_OutlineTech
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Model_Silhouette_Head_Outline1();
		PixelShader = compile ps_3_0 PS_Silhouette_Head_Outline();
	}

	pass P1
	{
		VertexShader = compile vs_3_0 VS_Model_Silhouette_Head_Outline2();
		PixelShader = compile ps_3_0 PS_Silhouette_Head_Outline();
	}

	pass P2
	{
		VertexShader = compile vs_3_0 VS_Model_Silhouette_Head_Outline3();
		PixelShader = compile ps_3_0 PS_Silhouette_Head_Outline();
	}

	pass P3
	{
		VertexShader = compile vs_3_0 VS_Model_Silhouette_Head_Outline4();
		PixelShader = compile ps_3_0 PS_Silhouette_Head_Outline();
	}
};
#endif

technique Character_AuraTech
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_ModelAura();
		PixelShader = compile ps_3_0 PS_ModelAura();
	}
};

technique CharacterTech
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Model();
		PixelShader = compile ps_3_0 PS_Model();
	}

	pass P1
	{
		VertexShader = compile vs_3_0 VS_Model();
		PixelShader = compile ps_3_0 PS_Model();
	}

	pass P2
	{
		VertexShader = compile vs_3_0 VS_Model_Outline();
		PixelShader = compile ps_3_0 PS_Model_Outline();
	}
};

technique Character_OutlineTech
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Model();
		PixelShader = compile ps_3_0 PS_Model();
	}

	pass P1
	{
		VertexShader = compile vs_3_0 VS_Model();
		PixelShader = compile ps_3_0 PS_Model();
	}

	pass P2
	{
		VertexShader = compile vs_3_0 VS_Model_Select_Outline();
		PixelShader = compile ps_3_0 PS_Model_Select_Outline();
	}
};

technique Character_Hair_Face_AccTech
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Model();
		PixelShader = compile ps_3_0 PS_Model_Head();
	}

	pass P1
	{
		VertexShader = compile vs_3_0 VS_Model();
		PixelShader = compile ps_3_0 PS_Model_Head();
	}
};

technique Character_FaceHair_OutlineTech
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Model();
		PixelShader = compile ps_3_0 PS_Model_Head();
	}

	pass P1
	{
		VertexShader = compile vs_3_0 VS_Model();
		PixelShader = compile ps_3_0 PS_Model_Head();
	}

	pass P2
	{
		VertexShader = compile vs_3_0 VS_Model_Head_Outline1();
		PixelShader = compile ps_3_0 PS_Model_Select_Outline();
	}

	pass P3
	{
		VertexShader = compile vs_3_0 VS_Model_Head_Outline2();
		PixelShader = compile ps_3_0 PS_Model_Select_Outline();
	}

	pass P4
	{
		VertexShader = compile vs_3_0 VS_Model_Head_Outline3();
		PixelShader = compile ps_3_0 PS_Model_Select_Outline();
	}

	pass P5
	{
		VertexShader = compile vs_3_0 VS_Model_Head_Outline4();
		PixelShader = compile ps_3_0 PS_Model_Select_Outline();
	}
};
#endif

#endif