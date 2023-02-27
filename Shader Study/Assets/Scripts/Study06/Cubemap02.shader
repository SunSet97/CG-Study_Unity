Shader "Custom/Cubemap02"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("Normalmap",2d) = "bump"{}
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
        sampler2D _BumpMap;
        samplerCUBE _Cube;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float3 worldRefl;
            INTERNAL_DATA//버텍스 노멀 데이터를 픽셀 노멀 데이터로 변환하기 위한 행렬이 가동됨.
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
            //노말맵이 적용된 월드 좌표계의 픽셀 노말을 뽑아서 큐브맵의 UV로 사용.
            float4 re=texCUBE(_Cube,WorldReflectionVector(IN,o.Normal));
            //반사 이미지는 albedo에 넣어야 할지, Emission에 넣어야 할지. 빛의 영향을 받는지에 대해 생각해본다. 반사재질은 주변을 반사하는것.
            //반사만 생각할 떄 빛을 비춘다고 거기에 영향을 받아 밝아지거나 어두워지는게 아니라 그저 이미지를 반사하는 것. 그래서 반사이미지는 o.Emission에 넣어야 한다.
            //o.Albedo = c.rgb;
            //이렇게 넣으면 이미 흰색이 들어가있는데에다 EMission에 반사이미지가 더해지면서 최종결과가 1이 한참 넘어가면서 물리적 법칙을 넘어서는 빛의 양이 됨.
            o.Albedo =c.rgb*0.5;
            //float4 re=texCUBE(_Cube,IN.worldRefl);
            //o.Normal=UnpackNormal(tex2D(_BumpMap,IN.uv_BumpMap));
            //일반적으로 노말을 적용하면 에러가 생기는 데, 그 이유는 Input에서 worldRefl와 worldNormal과 같이 버텍스 월드 노말에 관련된
            //데이터를 받아와 surf함수 내부에서 사용하면서, 동시에 탄젠트 노말인 UnpackNormal함수를 거친 노멀데이터를 함수 내부에서 같이 사용하면서 발생.
            //이를 해결하기 위해서는 NormalMap에 대응되는 반사 벡터를 원하니까 픽셀 월드 노멀로 변화하면 됨.
            o.Emission=re.rgb*0.5;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
