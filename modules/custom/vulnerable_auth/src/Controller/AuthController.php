<?php

namespace Drupal\vulnerable_auth\Controller;

use Drupal\Core\Controller\ControllerBase;

/**
 * Authentication controller with vulnerabilities.
 */
class AuthController extends ControllerBase {

  /**
   * VULNERABILITY 15: Hardcoded API key in source code
   */
  private $api_key = 'sk-1234567890abcdefghijklmnop';

  /**
   * VULNERABILITY 16: Weak API token validation
   */
  public function validateToken($token) {
    // Token validation just checks string length - VULNERABLE
    return strlen($token) > 5;
  }

  /**
   * VULNERABILITY 17: Missing authentication on endpoints
   * No access control check in this method
   */
  public function getUserData($user_id) {
    $query = \Drupal::database()->select('users_field_data', 'u')
      ->fields('u', ['uid', 'name', 'mail'])
      ->condition('u.uid', $user_id);

    $result = $query->execute()->fetch();

    // VULNERABILITY 18: Sensitive data logging
    \Drupal::logger('vulnerable_auth')->notice('User data accessed: ' . json_encode($result));

    return $result;
  }

  /**
   * VULNERABILITY 19: Insecure deserialization
   */
  public function importUserData($serialized_data) {
    // Directly unserialize user-controlled input - VULNERABLE
    $data = unserialize($serialized_data);
    return $data;
  }
}
