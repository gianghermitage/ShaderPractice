Shader "Unlit/specularReflection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightInt ("Light Intensity", Range(0, 1)) = 1

        SpecularTex ("Specular Texture", 2D) = "black" {}
        _SpecularInt ("Specular Intensity", Range(0, 1)) = 1
        _SpecularPow ("Specular Power", Range(1, 128)) = 64

    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "LightMode"="ForwardBase"

        }
        LOD 100

        Pass
        {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal_world : TEXCOORD1;
                float3 vertex_world : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _LightInt;
            float4 _LightColor0;

            sampler2D _SpecularTex;
            // float4 _SpecularTex_ST;
            float _SpecularInt;
            float _SpecularPow;
            float4 _LightColor1;


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal_world = UnityObjectToWorldNormal(v.normal);
                o.vertex_world = mul(unity_ObjectToWorld, v.vertex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            float3 LambertShading(float3 reflectionColor, float lightIntensity, float3 normal, float3 lightDir)
            {
                return reflectionColor * lightIntensity * max(0, dot(normal, lightDir));
            }


            float3 SpecularShading(float3 reflectionColor, float specularIntensity, float3 normal, float3 lightDir,
                                   float3 viewDir, float specularPow)
            {
                float3 halfway = normalize(lightDir + viewDir);
                return reflectionColor * specularIntensity * pow(max(0, dot(normal, halfway)), specularPow);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 normal = i.normal_world;
                fixed3 reflectionColor = _LightColor0.rgb;
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                half3 diffuse = LambertShading(reflectionColor, _LightInt, normal, lightDirection);
                // apply fog

                fixed3 reflectionColorSpec = _LightColor0.rgb;
                fixed3 specCol = tex2D(_SpecularTex, i.uv) * reflectionColorSpec;
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.vertex_world);


                half3 specular = SpecularShading(specCol, _SpecularInt, normal, lightDirection, viewDir, _SpecularPow)

                UNITY_APPLY_FOG(i.fogCoord, col);
                col.rgb *= diffuse;
                col.rgb += specular;
                return col;
            }
            ENDCG
        }
    }
}