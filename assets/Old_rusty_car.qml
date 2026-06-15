import QtQuick
import QtQuick3D

Node {
    id: node

    // Resources
    property url textureData: "maps/textureData.png"
    property url textureData11: "maps/textureData11.png"
    property url textureData13: "maps/textureData13.png"
    property url textureData19: "maps/textureData19.png"
    property url textureData25: "maps/textureData25.png"
    Texture {
        id: _0_texture
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData
    }
    Texture {
        id: _1_texture
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData11
    }
    Texture {
        id: _2_texture
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData13
    }
    Texture {
        id: _3_texture
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData19
    }
    Texture {
        id: _4_texture
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: node.textureData25
    }
    PrincipledMaterial {
        id: material_294_material
        objectName: "Material_294"
        baseColorMap: _0_texture
        metalnessMap: _1_texture
        roughnessMap: _1_texture
        metalness: 1
        roughness: 1
        normalMap: _2_texture
        occlusionMap: _1_texture
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    PrincipledMaterial {
        id: material_295_material
        objectName: "Material_295"
        baseColorMap: _3_texture
        metalnessMap: _1_texture
        roughnessMap: _1_texture
        metalness: 1
        roughness: 1
        normalMap: _2_texture
        occlusionMap: _1_texture
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Blend
    }
    PrincipledMaterial {
        id: material_316_material
        objectName: "Material_316"
        baseColorMap: _4_texture
        roughness: 1
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Blend
    }

    // Nodes:
    Node {
        id: sketchfab_model
        objectName: "Sketchfab_model"
        rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
        Node {
            id: oldcar_FBX
            objectName: "oldcar.FBX"
            rotation: Qt.quaternion(0.707107, 0.707107, 0, 0)
            Node {
                id: rootNode
                objectName: "RootNode"
                Node {
                    id: object006
                    objectName: "Object006"
                    position: Qt.vector3d(0, -4.76025, -2.08077e-07)
                    rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
                    Model {
                        id: object006_Material__294_0
                        objectName: "Object006_Material #294_0"
                        source: "meshes/object006_Material__294_0_mesh.mesh"
                        materials: [
                            material_294_material
                        ]
                    }
                }
                Node {
                    id: object007
                    objectName: "Object007"
                    position: Qt.vector3d(0, -4.76025, -2.08077e-07)
                    rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
                    Model {
                        id: object007_Material__295_0
                        objectName: "Object007_Material #295_0"
                        source: "meshes/object007_Material__295_0_mesh.mesh"
                        materials: [
                            material_295_material
                        ]
                    }
                }
                Node {
                    id: plane001
                    objectName: "Plane001"
                    position: Qt.vector3d(2.13043, 0, -46.3523)
                    rotation: Qt.quaternion(0.707107, -0.707107, 0, 0)
                    Model {
                        id: plane001_Material__316_0
                        objectName: "Plane001_Material #316_0"
                        source: "meshes/plane001_Material__316_0_mesh.mesh"
                        materials: [
                            material_316_material
                        ]
                    }
                }
            }
        }
    }

    // Animations:
}
