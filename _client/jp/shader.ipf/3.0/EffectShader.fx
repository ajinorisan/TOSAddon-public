#ifndef __EFFECTSHADER_HLSL__
#define __EFFECTSHADER_HLSL__

#define AlphaTest_Threshold	0.001f
#define AlphaTest(alpha)	if (alpha < AlphaTest_Threshold)	discard;

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
#define TexScreen(uv)	tex2D(ScreenSampler, uv)

texture g_texDepth;
sampler DepthSampler = sampler_state
{
	Texture = g_texDepth;
	AddressU = BORDER;
	AddressV = BORDER;
	AddressW = BORDER;
	MIPFILTER = POINT;
	MINFILTER = POINT;
	MAGFILTER = POINT;
	SRGBTEXTURE = FALSE;
};
#define TexDepth(uv)	tex2D(DepthSampler, uv)

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

////////////////////////////////////////////////////////////////////////////////////////////////////////
// global shader variables
////////////////////////////////////////////////////////////////////////////////////////////////////////

struct EffectVSData	// VS
{
	float4x4 viewProjMatrix;
	float4x4 screenProjectionMatrix;
};
EffectVSData g_effectVSData;

struct EncodedTransformData
{
	float4 matrix1;
	float4 matrix2;
	float4 matrix3;
};

struct EffectData
{
	float2 waveSpeed;
	float2 waveStretch;

	float2 wavePower;
	float effectTime;
	float overrideAlpha;

	float softParticleFactor;
	uint useUvAnimMask;
	float2 padding;
};
EffectData g_effectData;

#ifdef ENABLE_2D
struct Render2DData
{
	EncodedTransformData billBoardTransformData;
	EncodedTransformData charViewProjTransformData;
	float4 pivot;
};
Render2DData g_render2DData;
#endif

#ifdef ENABLE_MODEL
struct ModelData
{
	EncodedTransformData worldTransformData;
	EncodedTransformData uvAnimationTransformData;

	float4 color;

	uint vtfID;
	float3 padding;
};
ModelData g_modelData;
#endif

#ifdef ENABLE_DECAL

#ifndef eDecalInstancingCount
#define eDecalInstancingCount 16
#endif

struct DecalData
{
	EncodedTransformData worldTransformData;
	EncodedTransformData invWorldTransformData;
	float4 color;
};

struct DecalInstancingData
{
	float3 cameraPosition;
	float padding;

	DecalData decalData[eDecalInstancingCount];
};
DecalInstancingData g_decalInstancingData;
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

float4 ConvertColor(in float4 color)
{
	return float4(color.b, color.g, color.r, color.a);
}

static const float DepthBias = 0.0001f;
#ifdef ENABLE_2D	// 캐릭터 2D 렌더링
float4 CalcWVP(in float4 PosW, in float4x4 viewProjMatrix, in float4x4 charViewProjMatrix, in float4x4 billboardMatrix, in float4 pivotPoint)
{
	float worldPosY = PosW.y;
	PosW = mul(PosW, charViewProjMatrix);
	PosW /= PosW.w;
	PosW.z = 0.f;	// 빌보드로 만듦
	PosW.y += 0.4f;  // 캐릭터 발 위치를 맞추기 위한 상수
	PosW.xy *= (PosW.y * float2(0.5f, 0.2f) + 1.f);
	PosW = mul(PosW, billboardMatrix);
	PosW = mul(PosW, viewProjMatrix);
	// (Local Z - 카메라 거리 : Z값을 0 앞뒤로 맞추기 위함) * 적당히 납작하게 만들기 위한 상수 - 깊이 보정값

	float uprate = 1.1;
	float pivotOffset = 100;
	float4 pivotMul = mul(float4(pivotPoint.x, (worldPosY - pivotPoint.y + pivotOffset) * uprate + pivotPoint.y - pivotOffset, pivotPoint.z, 1), viewProjMatrix);
	float defz = pivotMul.z / pivotMul.w;
	PosW.z = defz * PosW.w;
	PosW.z -= DepthBias;
	return PosW;
}
#else
float4 CalcWVP(in float4 PosW, in float4x4 viewProjMatrix)
{
	float4 position = mul(PosW, viewProjMatrix);
	position.z -= DepthBias;
	return position;
}
#endif

float4 ShiftColor(float4 c)
{
	float gray = dot(c.rgb, float3(0.299, 0.587, 0.114));
    float3 silver = float3(gray, gray, gray) * 1.3f;
    float3 finalColor = lerp(silver, c.rgb, 0.15f);
    return float4(finalColor, c.a);
}

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

struct VS_OUT
{
	float4 position : POSITION;
	float4 color : COLOR;
	float4 texCoord : TEXCOORD0;
	float4 posWVP : TEXCOORD1;

#ifdef ENABLE_MODEL
	float3 normalW : TEXCOORD2;
#endif
};

VS_OUT VS_Effect(in float4 inPos : POSITION
	, float4 inColor : COLOR
	, float2 inTex0 : TEXCOORD0
)
{
	VS_OUT output = (VS_OUT)0;

	inPos.w = 1.f;

#ifdef ENABLE_2D
	Render2DData render2DData = g_render2DData;
	float4x4 billboardMatrix = DecodeMatrix(render2DData.billBoardTransformData);
	float4x4 charViewProjMatrix = DecodeMatrix(render2DData.charViewProjTransformData);
	output.position = CalcWVP(inPos, g_effectVSData.viewProjMatrix, charViewProjMatrix, billboardMatrix, render2DData.pivot);
#else
	output.position = CalcWVP(inPos, g_effectVSData.viewProjMatrix);
#endif

	output.color = ConvertColor(inColor);
	output.texCoord.xy = inTex0;
	output.posWVP = output.position;

	return output;
}

VS_OUT VS_ScreenEffect(in float4 inPos : POSITION
	, float4 inColor : COLOR
	, float2 inTex0 : TEXCOORD0
)
{
	VS_OUT output = (VS_OUT)0;

	inPos.w = 1.f;

	output.position = mul(g_effectVSData.screenProjectionMatrix, inPos);

	output.color = ConvertColor(inColor);
	output.texCoord.xy = inTex0;
	output.posWVP = output.position;

	return output;
}

#ifdef ENABLE_MODEL
VS_OUT VS_Model(in float4 inPos : POSITION
	, in float3 inNormal : NORMAL
	, in float2 inTex0 : TEXCOORD0
	, in float2 inTex1 : TEXCOORD1
#ifdef ENABLE_SKINNING
	, in float4 inBlendWeight : BLENDWEIGHT
	, in uint4 inBlendIndices : BLENDINDICES
#endif
)
{
	VS_OUT output = (VS_OUT)0;

	inPos.w = 1.f;

	float4 localPos = 0.f;
	float3 localNormal = 0.f;

#ifdef ENABLE_SKINNING
	inBlendWeight.w = 1.f - (inBlendWeight.x + inBlendWeight.y + inBlendWeight.z);
	ComputeSkinning(inPos, inNormal, inBlendWeight, inBlendIndices, g_modelData.vtfID, localPos, localNormal);
#else
	localPos = inPos;
	localNormal = inNormal;
#endif

	float4x4 worldMatrix = DecodeMatrix(g_modelData.worldTransformData);
	float4 posW = mul(localPos, worldMatrix);

#ifdef ENABLE_2D
	Render2DData render2DData = g_render2DData;
	float4x4 billboardMatrix = DecodeMatrix(render2DData.billBoardTransformData);
	float4x4 charViewProjMatrix = DecodeMatrix(render2DData.charViewProjTransformData);
	output.position = CalcWVP(posW, g_effectVSData.viewProjMatrix, charViewProjMatrix, billboardMatrix, render2DData.pivot);
#else
	output.position = CalcWVP(posW, g_effectVSData.viewProjMatrix);
#endif

#ifdef ENABLE_DIFFUSETEX_ANIMATION
	float4x4 uvAnimationMatrix = DecodeMatrix(g_modelData.uvAnimationTransformData);
	SetDiffuseTexCoord(inTex0, uvAnimationMatrix, output.texCoord);
#else
	SetDiffuseTexCoord(inTex0, output.texCoord);
#endif

	output.color = g_modelData.color;
	output.posWVP = output.position;
	output.normalW = normalize(mul(localNormal, (float3x3)worldMatrix));

	return output;
}
#endif

#ifdef ENABLE_DECAL
struct VS_OUT_Decal
{
	float4 position : POSITION;
	float3 viewRay : TEXCOORD0;
	float InstanceID : TEXCOORD1;
	float4 posWVP : TEXCOORD2;
};

VS_OUT_Decal VS_Decal(in float4 inPos : POSITION
	, in float _InstanceID : TEXCOORD0
)
{
	VS_OUT_Decal output = (VS_OUT_Decal)0;

	inPos.w = 1.f;

	int InstanceID = (int)(_InstanceID + 1e-5f);
	float4x4 worldMatrix = DecodeMatrix(g_decalInstancingData.decalData[InstanceID].worldTransformData);
	output.position = mul(inPos, worldMatrix);
	output.viewRay = output.position.xyz - g_decalInstancingData.cameraPosition;
	output.InstanceID = _InstanceID;

	output.position = mul(output.position, g_effectVSData.viewProjMatrix);
	output.posWVP = output.position;
	return output;
}
#endif

float2 GetScreenTex(float4 pos)
{
	pos.x /= pos.w;
	pos.y /= pos.w;

	float2 scrTexOut;
	scrTexOut.x = (pos.x + 1.0f) / 2;
	scrTexOut.y = (2.0f - (pos.y + 1.0f)) / 2;

	// ��ũ�� ������ (�����ѹ�)
	scrTexOut.x += 0.0005f;
	scrTexOut.y += 0.0006f;

	return scrTexOut;
}

float CalcAlphaWithDepth(float4 srcPos, float softParticleFactor)
{
#ifdef ENABLE_SOFT_PARTICLE
	float2 scrTexOut = GetScreenTex(srcPos);
	float pixelDepth = srcPos.z;
	float bgDepth = TexDepth(scrTexOut.xy).x * 1000.0f;
	float delta = (bgDepth - pixelDepth) * softParticleFactor + 1.f;
	return saturate(delta);
#else
	return 1.f;
#endif
}

float4 PS_Multiply(VS_OUT input) : COLOR0
{
	AlphaTest(input.color.a);

	EffectData effectData = g_effectData;

	float2 tex = input.texCoord.xy;
	tex.x = tex.x + (sin(tex.y * effectData.waveStretch.x + effectData.effectTime * effectData.waveSpeed.x) * effectData.wavePower.x);
	tex.y = tex.y + (sin(tex.x * effectData.waveStretch.y + effectData.effectTime * effectData.waveSpeed.y) * effectData.wavePower.y);

	float4 texColor = TexDiffuse(tex);
	float4 finalColor = texColor * input.color;

#ifdef ENABLE_REVERSE
	finalColor = ShiftColor(finalColor);
#endif

#ifdef ENABLE_RGB_SOFT_PARTICLE
	finalColor *= CalcAlphaWithDepth(input.posWVP, effectData.softParticleFactor);
#else
	finalColor.a *= CalcAlphaWithDepth(input.posWVP, effectData.softParticleFactor);
#endif

	finalColor.rgb *= effectData.overrideAlpha;
	finalColor.a *= effectData.overrideAlpha;

#ifdef ENABLE_DIFFUSETEX_ANIMATION
	uint useUvAnimMask = effectData.useUvAnimMask;
	if (useUvAnimMask != 0)
	{
		float4 mask = TexUvAnimationMask(input.texCoord.zw);
		finalColor.a *= mask.r;
	}
#endif

	return finalColor;
}

float4 PS_Additive(VS_OUT input) : COLOR0
{
	AlphaTest(input.color.a);

	float4 texColor = TexDiffuse(input.texCoord.xy);
	float4 finalColor = texColor * input.color;

#ifdef ENABLE_REVERSE
	finalColor = ShiftColor(finalColor);
#endif 

	EffectData effectData = g_effectData;

#ifdef ENABLE_RGB_SOFT_PARTICLE
	finalColor *= CalcAlphaWithDepth(input.posWVP, effectData.softParticleFactor);
#else
	finalColor.a *= CalcAlphaWithDepth(input.posWVP, effectData.softParticleFactor);
#endif

	finalColor.rgb *= effectData.overrideAlpha;

#ifdef ENABLE_DIFFUSETEX_ANIMATION
	uint useUvAnimMask = effectData.useUvAnimMask;
	if (useUvAnimMask != 0)
	{
		float4 mask = TexUvAnimationMask(input.texCoord.zw);
		finalColor.a *= mask.r;
	}
#endif

	return finalColor;
}

float4 PS_Exchange(VS_OUT input) : COLOR0
{
	AlphaTest(input.color.a);

	float4 texColor = TexDiffuse(input.texCoord.xy);
	float4 finalColor;
	finalColor.a = texColor.a * input.color.a;
	finalColor.rgb = input.color.rgb;

#ifdef ENABLE_REVERSE
	finalColor = ShiftColor(finalColor);
#endif 

	EffectData effectData = g_effectData;

#ifdef ENABLE_RGB_SOFT_PARTICLE
	finalColor *= CalcAlphaWithDepth(input.posWVP, effectData.softParticleFactor);
#else
	finalColor.a *= CalcAlphaWithDepth(input.posWVP, effectData.softParticleFactor);
#endif

	finalColor.rgb *= effectData.overrideAlpha;

#ifdef ENABLE_DIFFUSETEX_ANIMATION
	uint useUvAnimMask = effectData.useUvAnimMask;
	if (useUvAnimMask != 0)
	{
		float4 mask = TexUvAnimationMask(input.texCoord.zw);
		finalColor.a *= mask.r;
	}
#endif

	return finalColor;
}

#ifdef ENABLE_MODEL
float4 PS_Lighting(VS_OUT input) : COLOR0
{
	AlphaTest(input.color.a);

	static const float3 lightDirection = float3(0.f, -1.f, 0.f);
	float lightPower = saturate(dot(input.normalW, -lightDirection));

	float4 texColor = TexDiffuse(input.texCoord.xy);
	float4 finalColor = texColor;
	finalColor.a = texColor.a * input.color.a;
	finalColor.rgb = (texColor.rgb + input.color.rgb) * lightPower;

	EffectData effectData = g_effectData;

#ifdef ENABLE_DIFFUSETEX_ANIMATION
	uint useUvAnimMask = effectData.useUvAnimMask;
	if (useUvAnimMask != 0)
	{
		float4 mask = TexUvAnimationMask(input.texCoord.zw);
		finalColor.a *= mask.r;
	}
#endif

	return finalColor;
}
#endif

#ifdef ENABLE_DECAL
float4 PS_Decal(VS_OUT_Decal input) : COLOR0
{
	int InstanceID = (int)(input.InstanceID + 1e-5f);

	float2 screeenPos;
	screeenPos.x = input.posWVP.x / input.posWVP.w * 0.5f + 0.5f;
	screeenPos.y = -input.posWVP.y / input.posWVP.w * 0.5f + 0.5f;

	float depth = TexDepth(screeenPos).g * 1000.f;

	input.viewRay = normalize(input.viewRay);
	float4 pos = float4(g_decalInstancingData.cameraPosition + input.viewRay * depth, 1.f);

	float4x4 invWorldMatrix = DecodeMatrix(g_decalInstancingData.decalData[InstanceID].invWorldTransformData);

	float3 decalLocalPosition = mul(pos, invWorldMatrix).xyz;
	clip(0.5f - abs(decalLocalPosition));

	float2 decalUV = decalLocalPosition.xz + 0.5f;

	float distance = abs(decalLocalPosition.y);
	float4 color = TexDiffuse(decalUV);

	color = color * g_decalInstancingData.decalData[InstanceID].color;
	color.a *= (1.f - max((distance - 0.25f) / 0.25f, 0.f));

	return color;
}
#endif

technique Effect_Multiply
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Effect();
		PixelShader = compile ps_3_0 PS_Multiply();
	}
};

technique Effect_Additive
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Effect();
		PixelShader = compile ps_3_0 PS_Additive();
	}
};

technique Effect_Exchange
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Effect();
		PixelShader = compile ps_3_0 PS_Exchange();
	}
};

technique ScreenEffect_Multiply
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_ScreenEffect();
		PixelShader = compile ps_3_0 PS_Multiply();
	}
};

technique ScreenEffect_Additive
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_ScreenEffect();
		PixelShader = compile ps_3_0 PS_Additive();
	}
};

technique ScreenEffect_Exchange
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_ScreenEffect();
		PixelShader = compile ps_3_0 PS_Exchange();
	}
};

#ifdef ENABLE_MODEL
technique Model_Multiply
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Model();
		PixelShader = compile ps_3_0 PS_Multiply();
	}
};

technique Model_Additive
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Model();
		PixelShader = compile ps_3_0 PS_Additive();
	}
};

technique Model_Exchange
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Model();
		PixelShader = compile ps_3_0 PS_Exchange();
	}
};

technique Model_Lighting
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Model();
		PixelShader = compile ps_3_0 PS_Lighting();
	}
};
#endif

#ifdef ENABLE_DECAL
technique Decal
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS_Decal();
		PixelShader = compile ps_3_0 PS_Decal();
	}
};
#endif
#endif