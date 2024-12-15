struct GaussianBlurContents
{
	float sigma;
	float2 sourceDimensions;
	float padding;
};
GaussianBlurContents g_gaussianBlurContents;

texture g_texColor;
sampler ColorSampler = sampler_state
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

texture g_texDepth;
sampler DepthSampler = sampler_state
{
	Texture = g_texDepth;
	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
	MIPFILTER = POINT;
	MINFILTER = POINT;
	MAGFILTER = POINT;
	SRGBTEXTURE = FALSE;
};

#define RADIUS	6

float CalcGaussianWeight(int nSamplePoint)
{
	float g = 1.f / sqrt(2.f * 3.14159f * g_gaussianBlurContents.sigma * g_gaussianBlurContents.sigma);
	return (g * exp(-(nSamplePoint * nSamplePoint) / (2.f * g_gaussianBlurContents.sigma * g_gaussianBlurContents.sigma)));
}

struct PS_INPUT
{
	float2 tex : TEXCOORD0;
};

float4 GaussianBlurH_PS(PS_INPUT input) : COLOR0
{
	float4 color = 0.f;
	float2 uv = input.tex;

	for (int i = -RADIUS; i < RADIUS; ++i)
	{
		float fWeight = CalcGaussianWeight(i);
		uv.x = input.tex.x + (i / g_gaussianBlurContents.sourceDimensions.x);

		float4 f4Sample = tex2D(ColorSampler, uv);
		color += f4Sample * fWeight;
	}

	return color;
}

float4 GaussianBlurV_PS(PS_INPUT input) : COLOR0
{
	float4 color = 0.f;
	float2 uv = input.tex;

	for (int i = -RADIUS; i < RADIUS; ++i)
	{
		float fWeight = CalcGaussianWeight(i);
		uv.y = input.tex.y + (i / g_gaussianBlurContents.sourceDimensions.y);

		float4 f4Sample = tex2D(ColorSampler, uv);
		color += f4Sample * fWeight;
	}

	return color;
}

float4 GaussianDepthBlurH_PS(PS_INPUT input) : COLOR0
{
	float4 color = 0.f;
	float2 uv = input.tex;
	float4 centerColor = tex2D(ColorSampler, input.tex);
	float centerDepth = tex2D(DepthSampler,input.tex).x;

	{
		[unroll]
		for (int i = -RADIUS; i < 0; ++i)
		{
			uv.x = input.tex.x + (i / g_gaussianBlurContents.sourceDimensions.x);
			float depth = tex2D(DepthSampler, uv).x;
			float fWeight = CalcGaussianWeight(i);

			if (depth >= centerDepth)
			{
				float4 f4Sample = tex2D(ColorSampler, uv);
				color += f4Sample * fWeight;
			}
			else
			{
				color += centerColor * fWeight;
			}
		}
	}

	{
		[unroll]
		for (int i = 1; i < RADIUS; ++i)
		{
			uv.x = input.tex.x + (i / g_gaussianBlurContents.sourceDimensions.x);
			float depth = tex2D(DepthSampler, uv).x;
			float fWeight = CalcGaussianWeight(i);

			if (depth >= centerDepth)
			{
				float4 f4Sample = tex2D(ColorSampler, uv);
				color += f4Sample * fWeight;
			}
			else
			{
				color += centerColor * fWeight;
			}
		}
	}

	color += centerColor * CalcGaussianWeight(0);

	return color;
}

float4 GaussianDepthBlurV_PS(PS_INPUT input) : COLOR0
{
	float4 color = 0.f;
	float2 uv = input.tex;
	float4 centerColor = tex2D(ColorSampler, input.tex);
	float centerDepth = tex2D(DepthSampler, input.tex).x;

	{
		[unroll]
		for (int i = -RADIUS; i < 0; ++i)
		{
			uv.y = input.tex.y + (i / g_gaussianBlurContents.sourceDimensions.y);
			float depth = tex2D(DepthSampler, uv).x;
			float fWeight = CalcGaussianWeight(i);
			
			if (depth >= centerDepth)
			{
				float4 f4Sample = tex2D(ColorSampler, uv);
				color += f4Sample * fWeight;
			}
			else
			{
				color += centerColor * fWeight;
			}
		}
	}

	{
		[unroll]
		for (int i = 1; i < RADIUS; ++i)
		{
			uv.y = input.tex.x + (i / g_gaussianBlurContents.sourceDimensions.y);
			float depth = tex2D(DepthSampler, uv).x;
			float fWeight = CalcGaussianWeight(i);

			if (depth >= centerDepth)
			{
				float4 f4Sample = tex2D(ColorSampler, uv);
				color += f4Sample * fWeight;
			}
			else
			{
				color += centerColor * fWeight;
			}
		}
	}

	color += centerColor * CalcGaussianWeight(0);

	return color;
}

technique GaussianBlurH
{
	pass P0
	{
		VertexShader = null;
		PixelShader = compile ps_3_0 GaussianBlurH_PS();
	}
}

technique GaussianBlurV
{
	pass P0
	{
		VertexShader = null;
		PixelShader = compile ps_3_0 GaussianBlurV_PS();
	}
}

technique GaussianDepthBlurH
{
	pass P0
	{
		VertexShader = null;
		PixelShader = compile ps_3_0 GaussianDepthBlurH_PS();
	}
}

technique GaussianDepthBlurV
{
	pass P0
	{
		VertexShader = null;
		PixelShader = compile ps_3_0 GaussianDepthBlurV_PS();
	}
}