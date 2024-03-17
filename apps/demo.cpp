#include <iostream>
#include <fstream>
#include <cstdio>
#include <curl/curl.h>
#include <random>
#include <ctime>
#include <sstream>
#include <iomanip>
#include <zlib.h>
#include <cerrno> // for errno
#include <cstring> // for strerror

#define CHUNK 16384

// Function to generate a random string of specified length
std::string generate_random_string(int length) {
    const std::string charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    std::mt19937 gen(std::time(nullptr));
    std::uniform_int_distribution<> dist(0, charset.length() - 1);
    std::string random_string;
    for (int i = 0; i < length; ++i) {
        random_string += charset[dist(gen)];
    }
    return random_string;
}

// Function to compress a file using gzip
std::string compress_file(const std::string& filename) {
    std::ifstream ifs(filename, std::ios::binary);
    std::stringstream compressed_data;

    if (!ifs) {
        std::cerr << "Failed to open file: " << filename << std::endl;
        return "";
    }

    // Attempt to open the compressed file
    gzFile gf = gzopen((filename + ".gz").c_str(), "wb");
    if (gf == NULL) {
        std::cerr << "Failed to open compressed file: " << strerror(errno) << std::endl;
        return "";
    }

    char buffer[CHUNK];
    int num_read = 0;

    // Read from input file and write to compressed file
    while ((num_read = ifs.read(buffer, CHUNK).gcount()) > 0) {
        if (gzwrite(gf, buffer, num_read) != num_read) {
            std::cerr << "Failed to write to compressed file: " << strerror(errno) << std::endl;
            gzclose(gf);
            return "";
        }
    }

    // Close the compressed file
    if (gzclose(gf) != Z_OK) {
        std::cerr << "Failed to close compressed file: " << strerror(errno) << std::endl;
        return "";
    }

    // Generate a random string
    std::string random_suffix = generate_random_string(8);

    // Extract the file extension
    size_t dot_pos = filename.find_last_of(".");
    std::string extension = filename.substr(dot_pos);

    // Append the random string and the file extension
    std::string compressed_filename = filename.substr(0, dot_pos) + "_" + random_suffix + extension + ".gz";

    // Rename the compressed file
    if (rename((filename + ".gz").c_str(), compressed_filename.c_str()) != 0) {
        std::cerr << "Error renaming compressed file: " << strerror(errno) << std::endl;
        return "";
    }

    return compressed_filename;
}

// Function to upload a compressed file using curl
int upload_compressed_file(const std::string& compressed_filename, const std::string& original_filename) {
    CURL* curl;
    CURLcode res;

    // Initialize curl
    curl = curl_easy_init();
    if (!curl) {
        std::cerr << "Failed to initialize curl" << std::endl;
        return 1;
    }

    // Specify the URL to upload the file
    curl_easy_setopt(curl, CURLOPT_URL, "https://cod4mm.eu/api/promod/demo");

    // Set the file as the POST data
    struct curl_httppost* formpost = NULL;
    struct curl_httppost* lastptr = NULL;
    curl_formadd(&formpost, &lastptr, CURLFORM_COPYNAME, "file", CURLFORM_FILE, compressed_filename.c_str(), CURLFORM_END);
    curl_easy_setopt(curl, CURLOPT_HTTPPOST, formpost);

    // Perform the upload
    res = curl_easy_perform(curl);
    if (res != CURLE_OK) {
        std::cerr << "Failed to upload file: " << curl_easy_strerror(res) << std::endl;
        curl_easy_cleanup(curl);
        return 1;
    }

    // Clean up
    curl_easy_cleanup(curl);
    curl_formfree(formpost);

    // Delete the original file
    if (std::remove(original_filename.c_str()) != 0) {
        std::cerr << "Error deleting original file" << std::endl;
        return 1;
    }

    // Delete the compressed file
    if (std::remove(compressed_filename.c_str()) != 0) {
        std::cerr << "Error deleting compressed file" << std::endl;
        return 1;
    }

    return 0;
}

int main(int argc, char* argv[]) {
    if (argc != 2) {
        std::cerr << "Usage: " << argv[0] << " <filename>" << std::endl;
        return 1;
    }

    std::string filename = argv[1];
    std::string random_suffix = generate_random_string(8);
    std::string compressed_filename = compress_file(filename);

    // Upload the compressed file over HTTP using curl
    if (upload_compressed_file(compressed_filename, filename) != 0) {
        std::cerr << "Failed to upload file" << std::endl;
        return 1;
    }

    std::cout << "File uploaded successfully" << std::endl;

    //std::cout << "Press Enter to exit...";
    //std::cin.get();

    return 0;
}
