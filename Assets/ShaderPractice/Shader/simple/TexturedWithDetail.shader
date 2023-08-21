Shader "Unlit/TexturedWithDetail"
{
    Properties
    {
        _Tint ("Tint", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _DetailedTex ("Detail Texture", 2D) = "gray" {}

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
                float2 uvDetail : TEXCOORD1;
            };

            float4 _Tint;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _DetailedTex;
            float4 _DetailedTex_ST;


            interpolators vert(vertex_data v)
            {
                interpolators i;
                i.position = UnityObjectToClipPos(v.position);
                i.uv = TRANSFORM_TEX(v.uv, _MainTex);
                i.uvDetail = TRANSFORM_TEX(v.uv,_DetailedTex);
                return i;
            }

            float4 frag(interpolators i) : SV_Target
            {
                //return float4(i.uv,1,1);
                float4 color = tex2D(_MainTex, i.uv) * _Tint;

                //sample detailed texture
                //unity_ColorSpaceDouble: param to make sure there are no changes in color, depend on color space
                //ex: gamma space, sample texture 2 times so have to multiply by 2 to preserve color detail
                //linear space param = 4.59
                color *= tex2D(_DetailedTex, i.uvDetail) * unity_ColorSpaceDouble;
                return color;
            }
            ENDCG
        }
    }
}