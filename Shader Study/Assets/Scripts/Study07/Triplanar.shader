Shader "Custom/Triplanar"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;//월드를 받고 이를 UV로 만들자.
            float3 worldNormal;
        };

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            //위에서 보는 원하는 UV는 X와 Z방향임
            //FRONT는 XY, SIDE는 ZY임.
            float2 topUV=float2(IN.worldPos.x,IN.worldPos.z);
            float2 frontUV=float2(IN.worldPos.x,IN.worldPos.y);
            float2 sideUV=float2(IN.worldPos.z,IN.worldPos.y);
            //texture
            float4 topTex= tex2D(_MainTex,topUV);
            float4 frontTex=tex2D(_MainTex,frontUV);
            float4 sideTex=tex2D(_MainTex,sideUV);
            

            o.Albedo=lerp(topTex,frontTex,abs(IN.worldNormal.z));
            o.Albedo=lerp(o.Albedo,sideTex,abs(IN.worldNormal.x));
            o.Alpha=1;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
