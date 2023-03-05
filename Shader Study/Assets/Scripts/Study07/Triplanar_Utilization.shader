Shader "Custom/Triplanar_Utilization"
{
    Properties
    {
        [NoScaleOFfset]_MainTex ("TopTex (RGB)", 2D) = "white" {}
        _MainTexUV("tileU,tileV,offsetU,offsetV",Vector)=(1,1,0,0) 
        [NoScaleOFfset]_MainTex2 ("SideTex (RGB)", 2D) = "white" {}
        _MainTex2UV ("tileU,tileV,offsetU,offsetV",Vector)=(1,1,0,0)
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
        sampler2D _MainTex2;
        float4 _MainTexUV;
        float4 _MainTex2UV;

        struct Input
        {
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
            float4 topTex= tex2D(_MainTex,topUV*_MainTexUV.xy+_MainTexUV.zw);
            float4 frontTex=tex2D(_MainTex2,frontUV*_MainTex2UV.xy+_MainTex2UV.zw);
            float4 sideTex=tex2D(_MainTex2,sideUV*_MainTex2UV.xy+_MainTex2UV.zw);
            

            o.Albedo=lerp(topTex,frontTex,abs(IN.worldNormal.z));
            o.Albedo=lerp(o.Albedo,sideTex,abs(IN.worldNormal.x));
            o.Alpha=1;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
