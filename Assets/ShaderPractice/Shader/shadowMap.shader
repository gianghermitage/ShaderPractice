Shader "Unlit/shadowMap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        //shadow caster
        Pass
        {
            Name "Shadow Caster"
            Tags
            {
                "RenderType"="Opaque"
                "LightMode"="ShadowCaster"
            }
            ZWrite On


            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : POSITION;
            };


            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return 0;
            }
            ENDCG
        }

        Pass
        {
            Name "Shadow Map Texture"
            Tags
            {
                "RenderType"="Opaque"
                "LightMode"="ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
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
                float4 vertex : SV_POSITION;
                // declare the UV coordinates for the shadow map
                float4 shadowCoord : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _ShadowMapTexture;

            float4 NDCToUV(float4 clipPos)
            {
                float4 uv = clipPos;
                #if defined(UNITY_HALF_TEXEL_OFFSET )
                uv.xy = float2(uv.x, uv.y * _ProjectionParams.x) + uv.w * _ScreenParams.zw;
                #else
                uv.xy = float2(uv.x, uv.y * _ProjectionParams.x) + uv.w;
                #endif
                uv.xy = float2(uv.x / uv.w, uv.y / uv.w) * 0.5;
                return uv;
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.shadowCoord = NDCToUV(o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // save the shadow texture in the shadow variable
                fixed shadow = tex2D(_ShadowMapTexture, i.shadowCoord).a;
                col.rgb *= shadow;
                return col;
            }
            ENDCG

        }
    }
}