Shader "Unlit/TexturedWithDetail"
{
    Properties
    {
        _Tint ("Tint", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}

    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"


            struct vertex_data
            {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct interpolators
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            float4 _Tint;
            sampler2D _MainTex;
            float4 _MainTex_ST;


            
            interpolators vert(vertex_data v)
            {
                interpolators i;
                i.position = UnityObjectToClipPos(v.position);
                i.uv = TRANSFORM_TEX(v.uv, +_MainTex);
				return i;
            }

            float4 frag(interpolators i) : SV_Target
            {
                //return float4(i.uv,1,1);
                float4 color =  tex2D(_MainTex,i.uv) * _Tint;
                color *= tex2D(_MainTex, i.uv * 10);
                return color;
            }
            ENDCG
        }
    }
}
