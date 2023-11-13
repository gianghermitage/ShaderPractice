Shader "Unlit/simpleLightning"
{
    // Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

    Properties
    {
        _Tint ("Tint", Color) = (1,1,1,1)
        _MainTex ("Albedo", 2D) = "white" {}
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        //_SpecularTint ("Specular", Color) = (0.5, 0.5, 0.5)		
        [Gamma] _Metallic ("Metallic", Range(0, 1)) = 0

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
            #pragma vertex vert
            #pragma fragment frag
            #include "MyLighting.cginc"
            ENDCG
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardAdd"
            }
            
            //blend 2nd pass with 1st pass
            //if not the 2nd pass will replace 1st pass
            
            //additive blending
            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "MyLighting.cginc"
            ENDCG
        }
    }

}