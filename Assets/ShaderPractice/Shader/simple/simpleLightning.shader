Shader "Unlit/simpleLightning"
{
    // Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

    Properties
    {
        _Tint ("Tint", Color) = (1,1,1,1)
        _MainTex ("Albedo", 2D) = "white" {}
        [NoScaleOffset] _NormalMap ("Normals", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1
        [Gamma] _Metallic ("Metallic", Range(0, 1)) = 0
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        _DetailTex ("Detail Texture", 2D) = "gray" {}
        [NoScaleOffset] _DetailNormalMap ("Detail Normals", 2D) = "bump" {}
        _DetailBumpScale ("Detail Bump Scale", Float) = 1

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

        Pass
        {
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
            
			CGPROGRAM

			#pragma target 3.0

			#pragma vertex MyShadowVertexProgram 
			#pragma fragment MyShadowFragmentProgram

			#include "MyShadows.cginc"

			ENDCG
        }
    }

}