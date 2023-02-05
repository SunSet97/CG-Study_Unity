using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
//using TOZ;

namespace TOZEditor {

	public class VertexPainter : EditorWindow {
#region Editor Window
		//Variables
		private static VertexPainter window;

		[MenuItem("Window/TOZ/Tools/Vertex Painter")]
		private static void CreateWindow() {
			//Init window
			int x = 40, y = 40, w = 312, h = 198;
			window = (VertexPainter)GetWindow(typeof(VertexPainter), true);
			window.position = new Rect(x, y, w, h);
			window.minSize = new Vector2(w, h);
			window.maxSize = new Vector2(w, h);
			window.titleContent = new GUIContent("Vertex Painter");
			window.Show();
		}
#endregion Editor Window

		//Variables
		private static Color _r = new Color(1f, 0f, 0f, 0f);
		private static Color _g = new Color(0f, 1f, 0f, 0f);
		private static Color _b = new Color(0f, 0f, 1f, 0f);
		private static Color _a = new Color(0f, 0f, 0f, 1f);

		private GameObject go;
		private Collider coll;
		private MeshFilter mf;
		private Mesh mesh;
		private MeshRenderer mr;
		private Vector3[] vertices;
		private Color[] originalColors, debugColors;
		private Material originalMaterial, debugMaterial;

		//GUI Variables
		private bool canPaint;
		private bool tgl_Paint;
		private string str_Paint;
		private bool tgl_ShowVertexColors;
		private string str_ShowVertexColors;
		private string gui_Notification;
		private float gui_BrushSize;
		private float gui_BrushOpacity;
		private Color gui_BrushColor;

		//Mono Methods
		private void OnEnable() {
			SceneView.duringSceneGui += OnSceneGUI;

			//Create debug material
			if(debugMaterial == null) {
				debugMaterial = new Material(Shader.Find("TOZ/Debug/VertexColors"));
			}
			Initialize();
		}

		private void OnDisable() {
			SceneView.duringSceneGui -= OnSceneGUI;

			//Cleanup
			ResetMe();
			DestroyImmediate(debugMaterial);

			//Show ads
			AdsView.CreateWindow();
		}

		private void OnSelectionChange() {
			Initialize();
			this.Repaint();
		}

		private void OnProjectChange() {
			Initialize();
			this.Repaint();
		}

		private void OnInspectorUpdate() {
			this.Repaint();
		}

		private void OnGUI() {
			EditorGUILayout.BeginVertical();

			//Warnings
			if(!canPaint) {
				EditorGUILayout.HelpBox(gui_Notification, MessageType.Warning);
				return;
			}

			EditorGUILayout.BeginHorizontal("box");
			if(GUILayout.Button(str_Paint, GUILayout.Width(136))) {
				tgl_Paint = !tgl_Paint;
				if(tgl_Paint) {
					str_Paint = "STOP PAINTING";
					//Debug Material
					mr.sharedMaterial = debugMaterial;
					//Other button
					tgl_ShowVertexColors = true;
					str_ShowVertexColors = "HIDE COLORS";
				}
				else {
					str_Paint = "START PAINTING";
					Initialize();
				}
			}

			if(GUILayout.Button(str_ShowVertexColors, GUILayout.Width(136))) {
				tgl_ShowVertexColors = !tgl_ShowVertexColors;
				if(tgl_ShowVertexColors) {
					str_ShowVertexColors = "HIDE COLORS";
					//Debug Material
					mr.sharedMaterial = debugMaterial;
				}
				else {
					str_ShowVertexColors = "SHOW COLORS";
					mr.sharedMaterial = originalMaterial;
				}
			}

			if(GUILayout.Button("?", GUILayout.Width(22))) {
				Application.OpenURL("https://tozlab.com/documentation/toz-vertex-painter");
			}
			EditorGUILayout.EndHorizontal();

			if(tgl_Paint) {
				//Top
				EditorGUILayout.Space();
				EditorGUILayout.BeginVertical("box");
				gui_BrushSize = EditorGUILayout.Slider("Brush Size :", gui_BrushSize, 0.1f, 10.0f);
				gui_BrushOpacity = EditorGUILayout.Slider("Brush Opacity :", gui_BrushOpacity, 0.0f, 1.0f);
				EditorGUILayout.BeginHorizontal();
				EditorGUILayout.PrefixLabel("Brush Color :");
				if(GUILayout.Button("R", GUILayout.Width(22))) {
					gui_BrushColor = _r;
				}
				if(GUILayout.Button("G", GUILayout.Width(22))) {
					gui_BrushColor = _g;
				}
				if(GUILayout.Button("B", GUILayout.Width(22))) {
					gui_BrushColor = _b;
				}
				if(GUILayout.Button("A", GUILayout.Width(22))) {
					gui_BrushColor = _a;
				}
				gui_BrushColor = EditorGUILayout.ColorField(gui_BrushColor, GUILayout.Height(20));
				EditorGUILayout.EndHorizontal();
				EditorGUILayout.EndVertical();

				//Center
				EditorGUILayout.Space();
				EditorGUILayout.BeginHorizontal("box");
				EditorGUILayout.PrefixLabel("Vertex Colors :");
				if(GUILayout.Button("R", GUILayout.Width(22))) {
					DebugMeshColors(_r);
				}
				if(GUILayout.Button("G", GUILayout.Width(22))) {
					DebugMeshColors(_g);
				}
				if(GUILayout.Button("B", GUILayout.Width(22))) {
					DebugMeshColors(_b);
				}
				if(GUILayout.Button("A", GUILayout.Width(22))) {
					DebugMeshColors(_a);
				}
				if(GUILayout.Button("RESET", GUILayout.Width(50))) {
					mesh.colors = originalColors;
					EditorUtility.SetDirty(go);
				}
				EditorGUILayout.EndHorizontal();

				//Bottom
				EditorGUILayout.Space();
				if(GUILayout.Button("SAVE NEW MESH")) {
					string file = EditorUtility.SaveFilePanelInProject("Save Mesh", "New Mesh", "mat", "Please enter a file name");
					//string file = AssetDatabase.GenerateUniqueAssetPath("Assets/New Mesh.mat");
					if(file.Length != 0) {
						//Create an instance and save as new Mesh
						Mesh data = (Mesh)Instantiate(mesh);
						AssetDatabase.CreateAsset(data, file);
						AssetDatabase.SaveAssets();
						AssetDatabase.Refresh();
						Debug.LogWarning("Mesh is saved at location:" + file);
						//Revert original mesh colors
						ResetMe();
						EditorUtility.FocusProjectWindow();
						Selection.activeObject = data;
						//window.Close();
					}
				}
			}

			EditorGUILayout.EndVertical();
		}

		//Methods
		private void OnSceneGUI(SceneView sceneView) {
			if(!tgl_Paint) {
				return;
			}

			Event current = Event.current;
			Ray ray = HandleUtility.GUIPointToWorldRay(current.mousePosition);
			RaycastHit hit;
			//Events
			int controlID = GUIUtility.GetControlID(sceneView.GetHashCode(), FocusType.Passive);
			switch(current.GetTypeForControl(controlID)) {
				case EventType.Layout: {
					if(!tgl_Paint) {
						return;
					}
					HandleUtility.AddDefaultControl(controlID);
				}
				break;
				case EventType.MouseDown:
				case EventType.MouseDrag: {
					if(!tgl_Paint) {
						return;
					}
					if(current.alt || current.control) {
						return;
					}
					if(HandleUtility.nearestControl != controlID) {
						return;
					}
					if(current.GetTypeForControl(controlID) == EventType.MouseDrag && GUIUtility.hotControl != controlID) {
						return;
					}
					if(current.button != 0) {
						return;
					}

					if(current.type == EventType.MouseDown) {
						GUIUtility.hotControl = controlID;
					}
					//Do painting
					if(Physics.Raycast(ray, out hit, float.MaxValue)) {
						if(hit.transform == go.transform) {
							Vector3 hitPos = Vector3.Scale(go.transform.InverseTransformPoint(hit.point), go.transform.lossyScale);
							for(int i=0; i < vertices.Length; i++) {
								Vector3 vertPos = Vector3.Scale(vertices[i], go.transform.lossyScale);
								float mag = (vertPos - hitPos).magnitude;
								if(mag > gui_BrushSize)
									continue;
								debugColors[i] = Color.Lerp(debugColors[i], gui_BrushColor, gui_BrushOpacity);
							}
							mesh.colors = debugColors;
						}
					}
					current.Use();
				}
				break;
				case EventType.MouseUp: {
					if(!tgl_Paint) {
						return;
					}
					if(GUIUtility.hotControl != controlID) {
						return;
					}
					GUIUtility.hotControl = 0;
					current.Use();
				}
				break;
				case EventType.Repaint: {
					//Draw paint brush
					if(Physics.Raycast(ray, out hit, float.MaxValue)) {
						if(hit.transform == go.transform) {
							Handles.color = new Color(gui_BrushColor.r, gui_BrushColor.g, gui_BrushColor.b, 1.0f);
							Handles.DrawWireDisc(hit.point, hit.normal, gui_BrushSize, 2f);
						}
					}
					HandleUtility.Repaint();
				}
				break;
			}
		}

		private void ResetMe() {
			//Reset previously worked on object (if any)
			if(go && originalMaterial) {
				mesh.colors = originalColors;
				mr.sharedMaterial = originalMaterial;
			}

			//Reset variables
			go = null;
			coll = null;
			mf = null;
			mesh = null;
			mr = null;
			vertices = null;
			originalColors = null;
			debugColors = null;
			originalMaterial = null;

			//Reset gui variables
			canPaint = false;
			tgl_Paint = false;
			str_Paint = "START PAINTING";
			tgl_ShowVertexColors = false;
			str_ShowVertexColors = "SHOW COLORS";
			gui_BrushSize = 0.5f;
			gui_BrushOpacity = 0.5f;
			gui_BrushColor = _g;
		}

		private void Initialize() {
			ResetMe();

			//Reset selected object
			go = Selection.activeGameObject;
			if(go != null) {
				coll = go.GetComponent<Collider>();
				if(coll != null) {
					mf = go.GetComponent<MeshFilter>();
					if(mf != null) {
						mesh = mf.sharedMesh;
						if(mesh != null) {
							mr = go.GetComponent<MeshRenderer>();

							//Set Arrays
							vertices = mesh.vertices;
							originalColors = mesh.colors;
							originalMaterial = mr.sharedMaterial;
							if(mesh.colors.Length > 0) {
								debugColors = mesh.colors;
							}
							else {
								Debug.LogWarning("Mesh originally has no vertex color data!!");
								debugColors = new Color[vertices.Length];
								//DebugMeshColors(_r);
							}
							//All is okay, we can paint now
							canPaint = true;
						}
						else
							gui_Notification = "Object doesnt have a mesh!";
					}
					else
						gui_Notification = "Object doesnt have a MeshFilter!";
				}
				else
					gui_Notification = "Object doesnt have a collider!";
			}
			else
				gui_Notification = "No object selected!";
		}

		private void DebugMeshColors(Color col) {
			for(int i=0; i < debugColors.Length; i++) {
				debugColors[i] = col;
			}
			mesh.colors = debugColors;
			EditorUtility.SetDirty(go);
		}
	}

}