﻿Shader "Custom/Multiple Lightning"
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
			#pragma multi_compile _ VERTEXLIGHT_ON

            #pragma vertex MyVertexProgram
            #pragma fragment MyFragmentProgram

            #define FORWARD_BASE_PASS


            #include "CustomLightning.cginc"
            ENDCG
        }


        Pass
        {
            Tags
            {
                "LightMode" = "ForwardAdd"
            }
            
            Blend One One
            ZWrite Off
            CGPROGRAM
            #pragma target 3.0

            #pragma vertex MyVertexProgram
            #pragma fragment MyFragmentProgram

			#pragma multi_compile_fwdadd

            #include "CustomLightning.cginc"
            ENDCG
        }



    }
}