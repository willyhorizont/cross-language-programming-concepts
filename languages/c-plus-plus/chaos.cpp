#include "../../runtimes/c-plus-plus/runtime/willyhorizont/runtime.hpp"

int main() {
    // 1. Membuat List Heterogen (XlList) yang berisi berbagai tipe data
    XlList my_list;
    my_list.push_back(XlNone{});
    my_list.push_back(true);          // XlBool
    my_list.push_back(int64_t(9999)); // XlInt
    my_list.push_back(3.14159);       // XlFloat
    my_list.push_back("Halo Dunia");  // XlString

    CrossType xl_hetero_list = my_list;

    // 2. Membuat XlDictIndexed (Preserve Insertion Order)
    XlDictIndexed ordered_dict;
    ordered_dict.insert("nama", "XlRuntime");
    ordered_dict.insert("versi", int64_t(1));
    ordered_dict.insert("status", true);

    // 3. Membuat XlClosure (Anonymous function dengan getNextArguments)
    XlClosure tambah_angka = [](std::shared_ptr<XlClosureVarArgs> varargs) -> CrossType {
        // Mengambil argumen satu per satu secara dinamis
        CrossType arg1 = varargs->getNextArguments();
        CrossType arg2 = varargs->getNextArguments();

        // Mengambil data internal int64_t (asumsi input selalu XlInt demi kemudahan contoh)
        XlInt a = std::get<XlInt>(arg1.value);
        XlInt b = std::get<XlInt>(arg2.value);

        return CrossType(a + b); // Mengembalikan CrossType baru berisi XlInt
    };

    // Eksekusi Closure dengan Varargs
    auto args_obj = std::make_shared<XlClosureVarArgs>();
    args_obj->args.push_back(int64_t(50));
    args_obj->args.push_back(int64_t(25));

    CrossType hasil = tambah_angka(args_obj);
    
    std::cout << "Hasil Penjumlahan di XlClosure: " << std::get<XlInt>(hasil.value) << std::endl;

    return 0;
}
