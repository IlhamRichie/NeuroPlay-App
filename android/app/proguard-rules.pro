# Aturan untuk TensorFlow Lite
# Mencegah R8 menghapus atau mengubah nama kelas-kelas TFLite
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**