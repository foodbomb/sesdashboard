<?php


namespace App\Controller;


use App\Entity\Project;
use App\Repository\EmailRepository;
use App\Utils\WebHookProcessor;
use Aws\Sns\Message;
use Aws\Sns\MessageValidator;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Contracts\HttpClient\HttpClientInterface;

class WebHookController extends BaseController
{
    /**
     * @Route("/webhook/{token}", name="app_webhook", methods={"POST"})
     */
    public function index(Project $project,
                          Request $request,
                          EntityManagerInterface $em,
                          EmailRepository $emailRepository,
                          WebHookProcessor $processor,
                          HttpClientInterface $httpClient)
    {
        if(!$this->isRequestSignatureValid()) {
            return new Response('Unauthorized Request', Response::HTTP_FORBIDDEN);
        }

        $jsonData = json_decode($request->getContent(), true);
        if ($jsonData === false) {
            return new Response('Error', Response::HTTP_BAD_REQUEST);
        }

        // Auto subscribe to SNS topic.
        if (!empty($jsonData['Type']) && $jsonData['Type'] == 'SubscriptionConfirmation') {
            $response = $httpClient->request(
                'GET',
                $jsonData['SubscribeURL']
            );
            if ($response->getStatusCode() == Response::HTTP_OK) {
                return new Response('Ok');
            }
            return new Response('Not Ok', Response::HTTP_BAD_REQUEST);
        }

        $expectedKey = 'Message';
        if(array_key_exists($expectedKey, $jsonData)) {
            $jsonData = json_decode($jsonData[$expectedKey], true);
        }
        // Process mail.
        // Try to find mail.
        $email = $emailRepository->findOneBy([
            'project' => $project,
            'messageId' => $jsonData['mail']['messageId'],
        ]);

        // Create new mail.
        if (!$email) {
            $email = $processor->createEmailFromJson($jsonData);
            $email->setProject($project);
            $em->persist($email);
        }

        try {
            $emailEvent = $processor->createEvent($email, $jsonData);
        } catch (\Exception $e) {
            return new Response($e->getMessage(), Response::HTTP_BAD_REQUEST);
        }

        $em->persist($emailEvent);

        $em->flush();

        return new Response('Ok');
    }
    protected function isRequestSignatureValid(): bool
    {
        try {
            $message = Message::fromRawPostData();
            $validator = new MessageValidator();
            $validator->validate($message);
        } catch (Exception $e) {
//            Log::warning('Invalid SES Signature', context: ['exception' => $e]);
            print('Invalid SES Signature');
            return false;
        }

        return true;
    }
}
