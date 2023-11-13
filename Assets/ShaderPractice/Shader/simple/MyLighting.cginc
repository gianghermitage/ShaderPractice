#if !defined(MY_LIGHTING_INCLUDED)

#define MY_LIGHTING_INCLUDED

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
    float2 uv : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float3 worldPos : TEXCOORD2;
};

float4 _Tint;
sampler2D _MainTex;
float4 _MainTex_ST;
float _Smoothness;
//float4 _SpecularTint;
float _Metallic;


interpolators vert(vertex_data v)
{
    interpolators i;
    i.position = UnityObjectToClipPos(v.position);
    //i.normal = mul(unity_ObjectToWorld, float4(v.normal, 0));

    //calculate normal like this to account for object doesnt have 
    //uniform scale
    //i.normal = mul(
    //	transpose((float3x3)unity_WorldToObject),
    //	v.normal
    //);

    i.worldPos = mul(unity_ObjectToWorld, v.position);
    i.normal = UnityObjectToWorldNormal(v.normal);
    i.normal = normalize(i.normal);
    i.uv = TRANSFORM_TEX(v.uv, +_MainTex);
    return i;
}

float4 frag(interpolators i) : SV_Target
{
    //After producing correct normals in the vertex program, they are passed through the interpolator. Unfortunately, linearly interpolating between different unit-length vectors does not result in another unit-length vector. It will be shorter.
    //So we have to normalize the normals again in the fragment shader.
    i.normal = normalize(i.normal);
    float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;

    // energy conservation
    // only use the strongest component of specular color to reduce albedo
    //albedo *= 1 -
    //max(_SpecularTint.r, max(_SpecularTint.g, _SpecularTint.b));

    //unity utils
    // specular workflow
    // albedo = EnergyConservationBetweenDiffuseAndSpecular(
    //     albedo, _SpecularTint.rgb, oneMinusReflectivity
    // );


    float3 specularTint = albedo * _Metallic;
    float oneMinusReflectivity;
    albedo = DiffuseAndSpecularFromMetallic(
        albedo, _Metallic, specularTint, oneMinusReflectivity
    );
    //return float4(i.normal * 0.5 + 0.5, 1);
    float3 lightDir = _WorldSpaceLightPos0.xyz;

    float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

    float3 reflectionDir = reflect(-lightDir, i.normal);


    float3 lightColor = _LightColor0.rgb;
    float3 diffuse = albedo * lightColor * DotClamped(lightDir, i.normal);

    //blinn
    float4 colorBlinn = pow(
        DotClamped(viewDir, reflectionDir),
        _Smoothness * 100
    );

    //blinn phong
    float3 halfVector = normalize(lightDir + viewDir);

    float3 colorBlinnPhong = specularTint * lightColor * pow(
        DotClamped(halfVector, i.normal),
        _Smoothness * 100
    );

    //return float4(diffuse + colorBlinnPhong, 1);

    UnityLight light;
    light.color = lightColor;
    light.dir = lightDir;
    light.ndotl = DotClamped(i.normal, lightDir);

    UnityIndirect indirectLight;
    indirectLight.diffuse = 0;
    indirectLight.specular = 0;

    return UNITY_BRDF_PBS(
        albedo, specularTint,
        oneMinusReflectivity, _Smoothness,
        i.normal, viewDir, light, indirectLight
    );
}
#endif



