Shader "Custom/Blink"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("Normalmap",2D) = "bump"{}
        _MaskTex ("Mask",2D) = "white" {}
        _RampTex ("Ramp",2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _MaskTex;
        sampler2D _RampTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float2 uv_MaskTex;
            float2 uv_RampTex;
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
            o.Normal=UnpackNormal(tex2D(_BumpMap,IN.uv_BumpMap));
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            float4 m = tex2D (_MaskTex, IN.uv_MaskTex);
            float4 Ramp=tex2D(_RampTex, float2(_Time.y,0.5));
            // _Time.y는 x축으로 계속 우측으로 움직이면서, 0.5는 y축으로 처리하는 uv를 만들어서 적용하면 이미지의 X값을 참조하는 애니메이션 생성
            o.Albedo = c.rgb;
            o.Emission=c.rgb*m.g*Ramp.r;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}