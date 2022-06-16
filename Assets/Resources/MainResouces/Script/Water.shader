Shader "Unlit/Water"
{
	//プロパティ
	Properties
	{
		//メインテクスチャ
		_MainTex("Base (RGB)", 2D) = "white_Transparent" {}
		//色
		_Color("Main Color",Color) = (1,1,1,1)
		//法線マップ
		_NormalMap("Normal map",2D) = "Noise_Normal" {}
		//輝き度
		_Shininess("Shininess", Range(0.0,1.0)) = 0.05
	}

	//サブシェーダ―
	SubShader
	{
		//ブレンドモード
		//レンダ―タイプをTransparent(透明)にする
		Tags {"Queue" = "Transparent" "RenderType" = "Transparent"}

		//ブレンドモードをOneMinusSrcAlphaにする
		Blend SrcAlpha OneMinusSrcAlpha
		//モデルの詳細度
		LOD 100

		//パス
		Pass
		{
			//ライトモードを前方ベースにする
			Tags{"LightMode" = "ForwardBase"}

			//ここからCGプログラム開始
			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag
			//フォグを使用
			#pragma multi_compile_fog

			//光源の色
			float4 _LightColor0;
			//メインテクスチャ
			sampler2D _MainTex;
			//xyにはマテリアルのインスペクタで設定したタイリング値、zwにはオフセット値
			float4 _MainTex_ST;
			//法線マップ
			sampler2D _NormalMap;
			//オブジェクトの主な色
			fixed4 _Color;
			//輝き度
			half _Shininess;

			//appデータ
			struct appdata 
			{
				//位置
				float4 vertex : POSITION;
				//テクスチャ調整
				float2 texcoord : TEXCOORD0;
				//法線
				float3 normal : NORMAL;
				//正接
				float4 tangent : TANGENT;
			};

			//頂点データ用のパラメータ
			struct v2f 
			{
				//位置
				float4 pos : SV_POSITION;
				//テクスチャ調整
				half2 uv : TEXCOORD0;
				//光の向き
				half3 lightDir : TEXCOORD1;
				//ビューの向き
				half3 viewDir : TEXCOORD2;

				UNITY_FOG_COORDS(1)
			};

			//頂点シェーダ
			v2f vert(appdata v) 
			{
				v2f o;

				//波の動き
				{
					//シェーダ―に渡ってきた頂点座標をコピー
					o.pos = v.vertex;
					
					//全頂点を上下に反復させる
					//o.pos.y += sin(_Time * 10)
					//↓
					//頂点のx座標毎に差分を付ける
					//o.pos.y += sin(v.vertex.x + _Time * 10)
					//↓
					//頂点のz座標毎にも差分を付ける
					o.pos.y += 0.2 * sin((v.vertex.x + _Time * 10) + sin(v.vertex.z + _Time * 10));
					
					//MVP変換(モデル,ビュー,プロジェクション)
					o.pos = UnityObjectToClipPos(o.pos);
				}

				//テクスチャ調整
				o.uv  = v.texcoord.xy;

				// 接空間におけるライト方向のベクトルと視点方向のベクトルを求める
				TANGENT_SPACE_ROTATION;
				//行列のx,yの掛け算
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));

				return o;
			}

			//フラグメントシェーダ
			float4 frag(v2f i) : COLOR
			{
				//正規化
				i.lightDir = normalize(i.lightDir);
				i.viewDir = normalize(i.viewDir);
				//半方向
				half3 halfDir = normalize(i.lightDir + i.viewDir);
				//テクスチャ
				half4 tex = tex2D(_MainTex, i.uv);

				//法線
				half3 normal = UnpackNormal(tex2D(_NormalMap, i.uv));
				//UnpackNormal()
				//[テクスチャに0〜1で書き込まれている法線情報を -1〜1 の値に変換]
				
				//差分
				half4 diff = saturate(dot(normal, i.lightDir)) * _LightColor0;
				//saturate(飽和)
				//0か1に固定
				
				//スペック
				half3 spec = pow(max(0, dot(normal, halfDir)), _Shininess * 128.0) * _LightColor0.rgb * tex.rgb;

				//出力用の色情報colorに色々ぶち込む
				//テクスチャ
				fixed4 color = tex2D(_MainTex, i.uv) * _Color;

				//RGB
				color.rgb *= tex.rgb * diff + spec;
				//透明度(アルファ)
				color.a = _Color.a;

				//フォグを適用
				UNITY_APPLY_FOG(i.fogCoord, col);
				return color;

			}
			//ここまでCGプログラム
			ENDCG
		}
	}
}
