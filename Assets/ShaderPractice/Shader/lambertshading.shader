Shader "Unlit/lambertshading"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightInt ("Light Intensity", Range(0, 1)) = 1

    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            Tags { "LightMode"="ForwardBase" }

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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _LightInt;
            float4 _LightColor0;


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal_world = normalize(mul(unity_ObjectToWorld,
                                               float4(v.normal, 0))).xyz;
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            float3 LambertShading(float3 reflectionColor, float lightIntensity, float3 normal, float3 lightDir)
            {
                return reflectionColor * lightIntensity * max(0, dot(normal, lightDir));
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
                UNITY_APPLY_FOG(i.fogCoord, col);
                col.rgb *= diffuse;
                return col;
            }
            ENDCG
        }
    }
}