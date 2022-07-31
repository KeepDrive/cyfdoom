shader "CYF/DoomTransparentWall"
{
    Properties
    {
        _MainTex("Sprite Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags {"Queue" = "Transparent-1"}

        Cull Back
        Lighting Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;

            float4x4 MVP;

            float4 pos1, pos2, pos3, pos4;
            float4 uvpos12, uvpos34;

            v2f vert(appdata v)
            {
                v2f o;
                
                int arrIndex = int(v.uv.y * 2 + v.uv.x);
                
                MVP[0].y = 0;

                if (arrIndex == 0){
                    o.vertex = mul(MVP, pos1);
                    o.uv = uvpos12.xy;
                }else if (arrIndex == 1){
                    o.vertex = mul(MVP, pos2);
                    o.uv = uvpos12.zw;
                }else if(arrIndex == 2){
                    o.vertex = mul(MVP, pos3);
                    o.uv = uvpos34.xy;
                }else{
                    o.vertex = mul(MVP, pos4);
                    o.uv = uvpos34.zw;
                }
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return tex2D(_MainTex, i.uv);
            }
        ENDCG
        }
    }
}
