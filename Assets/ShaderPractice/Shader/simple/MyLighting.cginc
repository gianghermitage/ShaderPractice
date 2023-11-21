#if !defined(MY_LIGHTING_INCLUDED)
#define MY_LIGHTING_INCLUDED

#include "AutoLight.cginc"
#include "UnityPBSLighting.cginc"


struct vertex_data
{
    float4 position : POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
};

struct interpolators
{
    float4 position : SV_POSITION;
    float4 uv : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float3 worldPos : TEXCOORD2;

    #if defined(VERTEXLIGHT_ON)
    float3 vertexLightColor : TEXCOORD3;
    #endif
};

float4 _Tint;
sampler2D _MainTex;
float4 _MainTex_ST;
float _Smoothness;
float _Metallic;
sampler2D _NormalMap;
float _BumpScale;
sampler2D _DetailTex;
float4 _DetailTex_ST;



void ComputeVertexLightColor(inout interpolators i)
{
    #if defined(VERTEXLIGHT_ON)
    i.vertexLightColor = Shade4PointLights(
        unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
        unity_LightColor[0].rgb, unity_LightColor[1].rgb,
        unity_LightColor[2].rgb, unity_LightColor[3].rgb,
        unity_4LightAtten0, i.worldPos, i.normal
    );
    #endif
}

interpolators vert(vertex_data v)
{
    interpolators i;
    i.position = UnityObjectToClipPos(v.position);

    i.worldPos = mul(unity_ObjectToWorld, v.position);
    i.normal = UnityObjectToWorldNormal(v.normal);
    i.uv.xy = TRANSFORM_TEX(v.uv, +_MainTex);
    i.uv.zw = TRANSFORM_TEX(v.uv, +_DetailTex);
    ComputeVertexLightColor(i);
    return i;
}

UnityLight CreateLight(interpolators i)
{
    UnityLight light;

    #if defined(POINT)|| defined(SPOT) || defined(POINT_COOKIE)
    light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
    #else
    light.dir = _WorldSpaceLightPos0.xyz;
    #endif

    //light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);


    UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
    light.color = _LightColor0.rgb * attenuation;
    light.ndotl = DotClamped(i.normal, light.dir);
    return light;
}

UnityIndirect CreateIndirectLight(interpolators i)
{
    UnityIndirect indirectLight;
    indirectLight.diffuse = 0;
    indirectLight.specular = 0;

    #if defined(VERTEXLIGHT_ON)
    indirectLight.diffuse = i.vertexLightColor;
    #endif

    #if defined(FORWARD_BASE_PASS)
    indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));
    #endif

    return indirectLight;
}

void InitializeFragmentNormal(inout interpolators i)
{
    //normal map store data from range 0-1 so have to convert back to -1->1

    // //handle dxt5nm compression 
    // i.normal.xy = tex2D(_NormalMap, i.uv).wy * 2 - 1;
    // i.normal.xy *= _BumpScale;
    //
    // //since normals are unit vector
    // //x2 + y2 + z2 = 1 => calculate z
    // //clamp dot using saturate
    // i.normal.z = sqrt(1 - saturate(dot(i.normal.xy, i.normal.xy)));


    i.normal = UnpackScaleNormal(tex2D(_NormalMap, i.uv.xy), _BumpScale);


    //Swap y and z since normal map store z-UP
    i.normal = i.normal.xzy;

    i.normal = normalize(i.normal);
}

float4 frag(interpolators i) : SV_TARGET
{
    InitializeFragmentNormal(i);
    float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
    float3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Tint.rgb;

    float3 detail = tex2D(_DetailTex, i.uv.zw) * unity_ColorSpaceDouble;

    albedo *= detail;

    float3 specularTint;
    float oneMinusReflectivity;
    albedo = DiffuseAndSpecularFromMetallic(
        albedo, _Metallic, specularTint, oneMinusReflectivity
    );

    //	UnityIndirect indirectLight;
    //	indirectLight.diffuse = 0;
    //	indirectLight.specular = 0;

    return UNITY_BRDF_PBS(
        albedo, specularTint,
        oneMinusReflectivity, _Smoothness,
        i.normal, viewDir,
        CreateLight(i), CreateIndirectLight(i)
    );
}
#endif
