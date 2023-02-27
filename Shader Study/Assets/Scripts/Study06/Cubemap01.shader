Shader "Custom/Cubemap01"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Cube("Cubemap",Cube)=""{}
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

        sampler2D _MainTex;
        samplerCUBE _Cube;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldRefl;
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
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            float4 re=texCUBE(_Cube,IN.worldRefl);
            //반사 이미지는 albedo에 넣어야 할지, Emission에 넣어야 할지. 빛의 영향을 받는지에 대해 생각해본다. 반사재질은 주변을 반사하는것.
            //반사만 생각할 떄 빛을 비춘다고 거기에 영향을 받아 밝아지거나 어두워지는게 아니라 그저 이미지를 반사하는 것. 그래서 반사이미지는 o.Emission에 넣어야 한다.
            //o.Albedo = c.rgb;
            //이렇게 넣으면 이미 흰색이 들어가있는데에다 EMission에 반사이미지가 더해지면서 최종결과가 1이 한참 넘어가면서 물리적 법칙을 넘어서는 빛의 양이 됨.
            o.Albedo =c.rgb;
            o.Emission=re.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
