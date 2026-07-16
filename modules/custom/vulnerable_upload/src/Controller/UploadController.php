<?php

namespace Drupal\vulnerable_upload\Controller;

use Drupal\Core\Controller\ControllerBase;
use Symfony\Component\HttpFoundation\Request;

/**
 * File upload controller with vulnerabilities.
 */
class UploadController extends ControllerBase {

  /**
   * VULNERABILITY 22: Path traversal in upload handler
   */
  public function handleUpload(Request $request) {
    $filename = $request->request->get('filename');

    // VULNERABLE: No path validation - allows ../ sequences
    $upload_path = 'sites/default/files/' . $filename;

    if ($request->files->has('file')) {
      $file = $request->files->get('file');
      $file->move($upload_path);  // Could write outside intended directory

      return ['status' => 'uploaded', 'path' => $upload_path];
    }
  }

  /**
   * VULNERABILITY 23: No file type validation
   * VULNERABILITY 24: Executable file upload allowed
   */
  public function uploadFile($file_content, $filename) {
    // VULNERABLE: No file extension validation
    $allowed_types = [];  // Empty - no restrictions

    // VULNERABLE: No MIME type checking
    $upload_dir = 'sites/default/files/';
    $file_path = $upload_dir . basename($filename);

    file_put_contents($file_path, $file_content);
    chmod($file_path, 0755);  // VULNERABLE: Executable permissions

    return $file_path;
  }

  /**
   * VULNERABILITY 25: XXE (XML External Entity) injection
   */
  public function processXmlUpload($xml_content) {
    // VULNERABLE: No XXE protection
    $dom = new \DOMDocument();
    $dom->load($xml_content, LIBXML_NOENT | LIBXML_DTDLOAD);  // VULNERABLE: Enables external entities

    $elements = $dom->getElementsByTagName('item');
    $data = [];

    foreach ($elements as $element) {
      $data[] = $element->nodeValue;
    }

    return $data;
  }

  /**
   * VULNERABILITY 26: Insecure file permissions
   */
  public function storeUploadedFile($content, $filename) {
    $path = '/tmp/' . time() . '_' . $filename;
    file_put_contents($path, $content);
    chmod($path, 0777);  // VULNERABLE: World-writable
    return $path;
  }
}
