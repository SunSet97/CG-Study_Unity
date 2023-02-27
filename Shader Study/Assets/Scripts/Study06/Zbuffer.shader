Shader "Custom/Zbuffer"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert noambient noshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _CameraDeptrhTexture;

        struct Input
        {
            float4 screenPos;
        };


        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            float2 sPos=float2(IN.screenPos.x,IN.screenPos.y)/(IN.screenPos.w+0.000001);
            float4 Depth=tex2D(_CameraDeptrhTexture,sPos);
            o.Emission=Depth.rgb;
            o.Alpha = 1;
        }
        ENDCG
    }
    FallBack off
}
