// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Lightning Shader"
{


    Properties
    {
        _Tint("Tint",color) = (1,1,1,1)
        _MainTex ("Albedo",2D) = "white"{}
        [Gamma]_Metallic ("Metallic", Range(0, 1)) = 0
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
    }

    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }
            CGPROGRAM
            #pragma target 3.0


            #pragma vertex MyVertexProgram
            #pragma fragment MyFragmentProgram

            #include "UnityCG.cginc"
            //#include "UnityStandardBRDF.cginc"
            //#include "UnityStandardUtils.cginc"
            #include "UnityPBSLighting.cginc"


            float4 _Tint;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Metallic;

            float _Smoothness;

            struct Interpolators
            {
                float4 position: SV_POSITION;
                float3 normal : TEXCOORD1;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD2;
            };

            struct VertexData
            {
                float4 position: POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };


            Interpolators MyVertexProgram(VertexData v)
            {
                Interpolators i;
                i.uv = TRANSFORM_TEX(v.uv, _MainTex);
                i.worldPos = mul(unity_ObjectToWorld, v.position);
                i.position = UnityObjectToClipPos(v.position);
                i.normal = UnityObjectToWorldNormal(v.normal);
                i.normal = normalize(i.normal);
                return i;
            }

            float4 MyFragmentProgram(Interpolators i) : SV_TARGET
            {
                i.normal = normalize(i.normal);
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                //float3 reflectionDir = reflect(-lightDir, i.normal);
                float3 halfVector = normalize(lightDir + viewDir);

                float3 lightColor = _LightColor0.rgb;
                float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
                //albedo *= 1 -
                //	max(_SpecularTint.r, max(_SpecularTint.g, _SpecularTint.b));
                float3 specularTint;
                float oneMinusReflectivity;
                albedo = DiffuseAndSpecularFromMetallic(
                    albedo, _Metallic, specularTint, oneMinusReflectivity
                );

                float3 diffuse = albedo * lightColor * DotClamped(lightDir, i.normal);
                //return float4(diffuse,1);
                float3 specular = specularTint * lightColor * pow(
                    DotClamped(halfVector, i.normal),
                    _Smoothness * 100
                );
                return float4(diffuse + specular, 1);
            }
            ENDCG
        }
    }
}