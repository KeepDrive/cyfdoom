shader "CYF/DoomWall"
{
    Properties
    {
        _MainTex("Sprite Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
        }

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
                //float4 vertex   : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4x4 MVP;
            float4 pos1;
            float4 pos2;
            float4 pos3;
            float4 pos4;
            float4 uvpos12;
            float4 uvpos34;

            v2f vert(appdata v)
            {
                v2f o;
                int arrIndex=int(v.uv.y*2+v.uv.x);
                if (arrIndex==0){// I don't like this, you would usually refrain from branching in shaders, but i think this is fine for now. Rather this than make the positions unpersistent and get like a 50% performance loss
                    o.vertex = mul(MVP,pos1);
                    o.uv = uvpos12.xy;
                }else if(arrIndex==1){
                    o.vertex = mul(MVP,pos2);
                    o.uv = uvpos12.zw;
                }else if(arrIndex==2){
                    o.vertex = mul(MVP,pos3);
                    o.uv = uvpos34.xy;
                }else{
                    o.vertex = mul(MVP,pos4);
                    o.uv = uvpos34.zw;
                }
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                clip(color.a - 0.001);
                color.rgb *= color.a;
                return color;
            }
        ENDCG
        }
    }
}
