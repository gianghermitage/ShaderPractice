// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

#if !defined(MY_SHADOWS_INCLUDED)
#define MY_SHADOWS_INCLUDED

#include "UnityCG.cginc"

struct VertexData {
    float4 position : POSITION;
};

float4 MyShadowVertexProgram (VertexData v) : SV_POSITION {
    return UnityObjectToClipPos(v.position);
}

half4 MyShadowFragmentProgram () : SV_TARGET {
    return 0;
}

#endif