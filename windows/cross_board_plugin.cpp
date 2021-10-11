#include "include/cross_board/cross_board_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <winuser.h>

#include <map>
#include <memory>
#include <sstream>

namespace
{

  class CrossBoardPlugin : public flutter::Plugin
  {
  public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

    CrossBoardPlugin();

    virtual ~CrossBoardPlugin();

    // Method to paste text from clipboard.
    std::string PasteFromClipboard()
    {
      // Open the clipboard.
      if (!OpenClipboard(NULL))
      {
        return "";
      }

      // Get handle of clipboard object for ANSI text.
      HANDLE hData = GetClipboardData(CF_TEXT);
      if (hData == NULL)
      {
        CloseClipboard();
        return "";
      }

      // Lock the handle to get the actual text pointer.
      char *pszText = static_cast<char *>(GlobalLock(hData));
      if (pszText == NULL)
      {
        CloseClipboard();
        return "";
      }

      // Save text in a string class.
      std::string text(pszText);

      // Release the lock.
      GlobalUnlock(hData);

      // Close the clipboard.
      CloseClipboard();

      // Return the text.
      return text;
    }

    // Method to copy a string to the clipboard.
    void CopyToClipboard(const std::string &text)
    {
      if (OpenClipboard(NULL))
      {
        EmptyClipboard();
        HGLOBAL hg = GlobalAlloc(GMEM_MOVEABLE, text.size() + 1);
        if (hg)
        {
          memcpy(GlobalLock(hg), text.c_str(), text.size() + 1);
          GlobalUnlock(hg);
          SetClipboardData(CF_TEXT, hg);
        }
        CloseClipboard();
      }
    }

  private:
    // Called when a method is called on this plugin's channel from Dart.
    void HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  };

  // static
  void CrossBoardPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarWindows *registrar)
  {
    auto channel =
        std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(), "cross_board",
            &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<CrossBoardPlugin>();

    channel->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto &call, auto result)
        {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
  }

  CrossBoardPlugin::CrossBoardPlugin() {}

  CrossBoardPlugin::~CrossBoardPlugin() {}

  void CrossBoardPlugin::HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    // requestPermission
    if (method_call.method_name().compare("requestPermission") == 0)
    {
      // Get the permission.
      result->Success(flutter::EncodableValue(true));
    }
    // copy
    else if (method_call.method_name().compare("copy") == 0)
    {
      // Call CopyToClipboard method.
      if (std::holds_alternative<std::string>(method_call.arguments()[0]))
      {
        std::string text = std::get<std::string>(method_call.arguments()[0]);
        CopyToClipboard(text);
        result->Success(flutter::EncodableValue(true));
      }
    }
    // paste
    else if (method_call.method_name().compare("paste") == 0)
    {
      // Call PasteFromClipboard method.
      std::string text = PasteFromClipboard();
      result->Success(flutter::EncodableValue(text));
    }
    else
    {
      result->NotImplemented();
    }
  }

} // namespace

void CrossBoardPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar)
{
  CrossBoardPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
