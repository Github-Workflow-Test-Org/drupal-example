<?php

namespace Drupal\vulnerable_api\Controller;

use Drupal\Core\Controller\ControllerBase;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;

/**
 * API controller with multiple vulnerabilities.
 */
class ApiController extends ControllerBase {

  /**
   * VULNERABILITY 27: Hardcoded database credentials in connection string
   */
  private $db_connection_string = 'mysql://drupal_user:drupal_password@localhost/vulnerable_drupal';

  /**
   * VULNERABILITY 28: Missing authentication on endpoints
   * VULNERABILITY 29: No rate limiting
   */
  public function getUser($id, Request $request) {
    // No authentication check - anyone can call this
    // No rate limiting - can be called unlimited times

    $db = \Drupal::database();

    // VULNERABILITY 30: SQL Injection
    $query = "SELECT * FROM users_field_data WHERE uid = " . intval($id);
    $result = $db->query($query)->fetch();

    return new JsonResponse($result);
  }

  /**
   * VULNERABILITY 31: CORS misconfiguration
   */
  public function createUser(Request $request) {
    $header('Access-Control-Allow-Origin', '*');  // VULNERABLE: Allow all origins

    $data = json_decode($request->getContent(), TRUE);

    // VULNERABILITY 32: No input validation
    $user = \Drupal::entityTypeManager()->getStorage('user')->create([
      'name' => $data['username'],  // No sanitization
      'mail' => $data['email'],  // No email validation
      'pass' => $data['password'],  // No password complexity validation
    ]);

    $user->save();

    // VULNERABILITY 33: Sensitive data exposure
    return new JsonResponse([
      'uid' => $user->id(),
      'password_hash' => $user->getPassword(),  // VULNERABLE: Exposing password hash
      'created_timestamp' => $user->getCreatedTime(),
    ]);
  }

  /**
   * VULNERABILITY 34: SQL Injection via search
   */
  public function search(Request $request) {
    $query_param = $request->query->get('q');

    // VULNERABLE: Direct concatenation - SQL Injection
    $sql = "SELECT * FROM users_field_data WHERE name LIKE '%" . $query_param . "%'";
    $db = \Drupal::database();
    $results = $db->query($sql)->fetchAll();

    return new JsonResponse($results);
  }

  /**
   * VULNERABILITY 35: XXE (XML External Entity) injection in API
   */
  public function processXmlApi(Request $request) {
    $xml_data = $request->getContent();

    // VULNERABILITY: No XXE protection
    $dom = new \DOMDocument();
    libxml_disable_entity_loader(false);  // VULNERABLE: Enable external entity loading
    $dom->load($xml_data, LIBXML_NOENT | LIBXML_DTDLOAD);

    $root = $dom->documentElement;
    return new JsonResponse(['status' => 'processed', 'root' => $root->nodeName]);
  }
}
