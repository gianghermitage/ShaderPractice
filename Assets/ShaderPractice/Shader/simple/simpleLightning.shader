Shader "Unlit/simpleLightning"
{
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

    Properties
    {
        _Tint ("Tint", Color) = (1,1,1,1)
		_MainTex ("Albedo", 2D) = "white" {}

    }
    SubShader
    {
        Pass
        {
            Tags {
				"LightMode" = "ForwardBase"
			}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#include "UnityStandardBRDF.cginc"

            struct vertex_data
            {
                float4 position : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            
            struct interpolators
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
            };

            float4 _Tint;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            interpolators vert(vertex_data v)
            {
                interpolators i;
                i.position = UnityObjectToClipPos(v.position);
                //i.normal = mul(unity_ObjectToWorld, float4(v.normal, 0));

                //calculate normal like this to account for object doesnt have 
                //uniform scale
                //i.normal = mul(
				//	transpose((float3x3)unity_WorldToObject),
				//	v.normal
				//);

                i.normal = UnityObjectToWorldNormal(v.normal);
                i.normal = normalize(i.normal);
                i.uv = TRANSFORM_TEX(v.uv, +_MainTex);
				return i;
            }

            float4 frag(interpolators i) : SV_Target
            {
                //After producing correct normals in the vertex program, they are passed through the interpolator. Unfortunately, linearly interpolating between different unit-length vectors does not result in another unit-length vector. It will be shorter.
                //So we have to normalize the normals again in the fragment shader.
            	i.normal = normalize(i.normal);
                    float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;

				//return float4(i.normal * 0.5 + 0.5, 1);
                float3 lightDir = _WorldSpaceLightPos0.xyz;

				float3 lightColor = _LightColor0.rgb;
				float3 diffuse = albedo * lightColor * DotClamped(lightDir, i.normal);
				return float4(diffuse, 1);

            }
            ENDCG
        }
    }

}
