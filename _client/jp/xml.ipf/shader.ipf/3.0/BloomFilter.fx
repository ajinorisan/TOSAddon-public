struct Contents
{
	//Needed for pixel offset
	float2 InverseResolution;

	//The threshold of pixels that are brighter than that.
	float Threshold;

	//MODIFIED DURING RUNTIME, CHANGING HERE MAKES NO DIFFERENCE;
	float Radius;
	float Strength;

	//How far we stretch the pixels
	float StreakLength;

	float2 padding;
};
Contents g_contents;

texture ScreenTexture;
sampler LinearSampler = sampler_state
{
	Texture = ScreenTexture;
	AddressU = CLAMP;
	AddressV = CLAMP;
	AddressW = CLAMP;
	MIPFILTER = LINEAR;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	SRGBTEXTURE = FALSE;
};

struct PS_INPUT
{
	float2 tex : TEXCOORD0;
};

//Just an average of 4 values.
float4 Box4(float4 p0, float4 p1, float4 p2, float4 p3)
{
	return (p0 + p1 + p2 + p3) * 0.25f;
}

//Extracts the pixels we want to blur
float4 ExtractPS(float2 texCoord : TEXCOORD0) : COLOR0
{
	float4 color = tex2D(LinearSampler, texCoord);

	float avg = (color.r + color.g + color.b) / 3;

	if (avg>g_contents.Threshold)
	{
		return color * (avg - g_contents.Threshold) / (1 - g_contents.Threshold);// * (avg - g_contents.Threshold);
	}

	return float4(0, 0, 0, 0);
}

//Extracts the pixels we want to blur, but considers luminance instead of average rgb
float4 ExtractLuminancePS(float2 texCoord : TEXCOORD0) : COLOR0
{
	float4 color = tex2D(LinearSampler, texCoord);

	float luminance = color.r * 0.21f + color.g * 0.72f + color.b * 0.07f;

	if (luminance>g_contents.Threshold)
	{
		return color * (luminance - g_contents.Threshold) / (1 - g_contents.Threshold);// *(luminance - g_contents.Threshold);
																 //return saturate((color - g_contents.Threshold) / (1 - g_contents.Threshold));
	}

	return float4(0, 0, 0, 0);
}

//Downsample to the next mip, blur in the process
float4 DownsamplePS(float2 texCoord : TEXCOORD0) : COLOR0
{
	float2 offset = float2(g_contents.StreakLength * g_contents.InverseResolution.x, 1 * g_contents.InverseResolution.y);

	float4 c0 = tex2D(LinearSampler, texCoord + float2(-2, -2) * offset);
	float4 c1 = tex2D(LinearSampler, texCoord + float2(0,-2) * offset);
	float4 c2 = tex2D(LinearSampler, texCoord + float2(2, -2) * offset);
	float4 c3 = tex2D(LinearSampler, texCoord + float2(-1, -1) * offset);
	float4 c4 = tex2D(LinearSampler, texCoord + float2(1, -1) * offset);
	float4 c5 = tex2D(LinearSampler, texCoord + float2(-2, 0) * offset);
	float4 c6 = tex2D(LinearSampler, texCoord);
	float4 c7 = tex2D(LinearSampler, texCoord + float2(2, 0) * offset);
	float4 c8 = tex2D(LinearSampler, texCoord + float2(-1, 1) * offset);
	float4 c9 = tex2D(LinearSampler, texCoord + float2(1, 1) * offset);
	float4 c10 = tex2D(LinearSampler, texCoord + float2(-2, 2) * offset);
	float4 c11 = tex2D(LinearSampler, texCoord + float2(0, 2) * offset);
	float4 c12 = tex2D(LinearSampler, texCoord + float2(2, 2) * offset);

	return Box4(c0, c1, c5, c6) * 0.125f +
		Box4(c1, c2, c6, c7) * 0.125f +
		Box4(c5, c6, c10, c11) * 0.125f +
		Box4(c6, c7, c11, c12) * 0.125f +
		Box4(c3, c4, c8, c9) * 0.5f;
}

//Upsample to the former MIP, blur in the process
float4 UpsamplePS(float2 texCoord : TEXCOORD0) : COLOR0
{
	float2 offset = float2(g_contents.StreakLength * g_contents.InverseResolution.x, 1 * g_contents.InverseResolution.y) * g_contents.Radius;

	float4 c0 = tex2D(LinearSampler, texCoord + float2(-1, -1) * offset);
	float4 c1 = tex2D(LinearSampler, texCoord + float2(0, -1) * offset);
	float4 c2 = tex2D(LinearSampler, texCoord + float2(1, -1) * offset);
	float4 c3 = tex2D(LinearSampler, texCoord + float2(-1, 0) * offset);
	float4 c4 = tex2D(LinearSampler, texCoord);
	float4 c5 = tex2D(LinearSampler, texCoord + float2(1, 0) * offset);
	float4 c6 = tex2D(LinearSampler, texCoord + float2(-1,1) * offset);
	float4 c7 = tex2D(LinearSampler, texCoord + float2(0, 1) * offset);
	float4 c8 = tex2D(LinearSampler, texCoord + float2(1, 1) * offset);

	//Tentfilter  0.0625f    
	return 0.0625f * (c0 + 2 * c1 + c2 + 2 * c3 + 4 * c4 + 2 * c5 + c6 + 2 * c7 + c8) * g_contents.Strength + float4(0, 0, 0, 0); //+ 0.5f * ScreenTexture.Sample(c_texture, texCoord);
}

//Upsample to the former MIP, blur in the process, change offset depending on luminance
float4 UpsampleLuminancePS(float2 texCoord : TEXCOORD0) : COLOR0
{
	float4 c4 = tex2D(LinearSampler, texCoord);  //middle one

	/*float luminance = c4.r * 0.21f + c4.g * 0.72f + c4.b * 0.07f;
	luminance = max(luminance, 0.4f);
	*/
	float2 offset = float2(g_contents.StreakLength * g_contents.InverseResolution.x, 1 * g_contents.InverseResolution.y) * g_contents.Radius; /// luminance;

	float4 c0 = tex2D(LinearSampler, texCoord + float2(-1, -1) * offset);
	float4 c1 = tex2D(LinearSampler, texCoord + float2(0, -1) * offset);
	float4 c2 = tex2D(LinearSampler, texCoord + float2(1, -1) * offset);
	float4 c3 = tex2D(LinearSampler, texCoord + float2(-1, 0) * offset);
	float4 c5 = tex2D(LinearSampler, texCoord + float2(1, 0) * offset);
	float4 c6 = tex2D(LinearSampler, texCoord + float2(-1, 1) * offset);
	float4 c7 = tex2D(LinearSampler, texCoord + float2(0, 1) * offset);
	float4 c8 = tex2D(LinearSampler, texCoord + float2(1, 1) * offset);

	return 0.0625f * (c0 + 2 * c1 + c2 + 2 * c3 + 4 * c4 + 2 * c5 + c6 + 2 * c7 + c8) * g_contents.Strength + float4(0, 0, 0, 0); //+ 0.5f * ScreenTexture.Sample(c_texture, texCoord);
}

float4 ApplyPS(float2 texCoord : TEXCOORD0) : COLOR0
{
	return tex2D(LinearSampler, texCoord);
}

technique Extract
{
	pass P0
	{
		VertexShader = null;
		PixelShader = compile ps_3_0 ExtractPS();
	}
}

technique ExtractLuminance
{
	pass P0
	{
		VertexShader = null;
		PixelShader = compile ps_3_0 ExtractLuminancePS();
	}
}

technique Downsample
{
	pass P0
	{
		VertexShader = null;
		PixelShader = compile ps_3_0 DownsamplePS();
	}
}

technique Upsample
{
	pass P0
	{
		VertexShader = null;
		PixelShader = compile ps_3_0 UpsamplePS();
	}
}

technique UpsampleLuminance
{
	pass P0
	{
		VertexShader = null;
		PixelShader = compile ps_3_0 UpsampleLuminancePS();
	}
}

technique Apply
{
	pass P0
	{
		VertexShader = null;
		PixelShader = compile ps_3_0 ApplyPS();
	}
}