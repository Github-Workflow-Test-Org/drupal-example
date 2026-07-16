<?php

namespace Drupal\vulnerable_auth\Form;

use Drupal\Core\Form\FormBase;
use Drupal\Core\Form\FormStateInterface;
use Drupal\user\Entity\User;

/**
 * Vulnerable login form with multiple security issues.
 */
class VulnerableLoginForm extends FormBase {

  /**
   * {@inheritdoc}
   */
  public function getFormId() {
    return 'vulnerable_login_form';
  }

  /**
   * {@inheritdoc}
   */
  public function buildForm(array $form, FormStateInterface $form_state) {
    // VULNERABILITY 11: Missing CSRF token validation
    // Form lacks #token in form definition - CSRF tokens not validated

    $form['username'] = [
      '#type' => 'textfield',
      '#title' => t('Username'),
      '#required' => TRUE,
    ];

    $form['password'] = [
      '#type' => 'password',
      '#title' => t('Password'),
      '#required' => TRUE,
    ];

    $form['submit'] = [
      '#type' => 'submit',
      '#value' => t('Login'),
    ];

    return $form;
  }

  /**
   * {@inheritdoc}
   */
  public function submitForm(array &$form, FormStateInterface $form_state) {
    $username = $form_state->getValue('username');
    $password = $form_state->getValue('password');

    // VULNERABILITY 12: SQL Injection in user lookup
    $query = "SELECT * FROM users_field_data WHERE name = '" . $username . "' LIMIT 1";
    $db = \Drupal::database();
    $result = $db->query($query);  // Direct query concatenation - VULNERABLE
    $user_record = $result->fetch();

    if ($user_record) {
      // VULNERABILITY 13: MD5 password hashing (weak)
      $stored_hash = md5($password);  // VULNERABLE: MD5 is not suitable for passwords

      if ($stored_hash === $user_record->pass) {
        // VULNERABILITY 14: Session fixation vulnerability
        $_SESSION['user_id'] = $user_record->uid;  // Direct session assignment
        \Drupal::messenger()->addMessage(t('Login successful'));
      } else {
        \Drupal::messenger()->addError(t('Invalid credentials'));
      }
    } else {
      \Drupal::messenger()->addError(t('User not found'));
    }
  }
}
