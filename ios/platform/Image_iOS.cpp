#include "common/Image.h"
namespace RGBA8Image {
  std::optional<std::vector<u8>> LoadFromFile(
    const char* path, u32* width, u32* height) {
    return std::nullopt;
  }
  bool SaveToFile(const char* path, u32 width,
    u32 height, const u8* data) {
    return false;
  }
}
