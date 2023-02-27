Shader "Custom/NormalTest2"
{
    Properties
    {
        _BumpMap("Normalmap",2d) = "bump"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert noambient
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _BumpMap;

        struct Input
        {
            float2 uv_BumpMap;
            float3 worldNormal;
            INTERNAL_DATA
        };

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            //o.Normal=UnpackNormal(tex2D(_BumpMap,IN.uv_BumpMap));
            o.Emission=IN.worldNormal;//버텍스 월드 노말을 받아서 출력. 버텍스 사이에 Interpolation 이 보임.
            o.Alpha = 1;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
