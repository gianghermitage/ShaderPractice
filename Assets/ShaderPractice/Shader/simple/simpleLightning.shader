Shader "Unlit/simpleLightning"
{
    // Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

    Properties
    {
        _Tint ("Tint", Color) = (1,1,1,1)
        _MainTex ("Albedo", 2D) = "white" {}
        [NoScaleOffset] _HeightMap ("Heights", 2D) = "gray" {}
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
            #pragma target 3.0
            #pragma multi_compile _ VERTEXLIGHT_ON
            #define FORWARD_BASE_PASS

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

            //second pass has the same depth as prev pass cuz its for the same object 
            // => disable zWrite since writing to the depth buffer twice is not necessary
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma target 3.0

            #pragma multi_compile_fwdadd
            // == #pragma multi_compile DIRECTIONAL POINT SPOT DIRECTIONAL_COOKIE

            #include "MyLighting.cginc"
            ENDCG
        }
    }

}