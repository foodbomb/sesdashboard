<?php

namespace App\Command;

use App\Entity\Project;
use App\Entity\User;
use App\Repository\ProjectRepository;
use App\Repository\UserRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Exception\InvalidArgumentException;
use Symfony\Component\Console\Exception\RuntimeException;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;

class CreateProjectCommand extends Command
{
    protected static $defaultName = 'app:create-project';

    /**
     * @var SymfonyStyle
     */
    private $io;

    private $entityManager;

    private $project;

    private $users;

    public function __construct(EntityManagerInterface $em, ProjectRepository $project, UserRepository $users)
    {
        parent::__construct();

        $this->entityManager = $em;
        $this->project = $project;
        $this->users = $users;
    }


    protected function configure()
    {
        $this
            ->setDescription('Creates a new project.')
            ->setHelp($this->getCommandHelp())
            ->addArgument('userEmail', InputArgument::REQUIRED, 'The userEmail for the new project (must already exist)')
            ->addArgument('name', InputArgument::REQUIRED, 'The name for the new project')
            ->addArgument('token', InputArgument::REQUIRED, 'The token (webhook endpoint identifier) for the new project')
        ;
    }

    protected function initialize(InputInterface $input, OutputInterface $output): void
    {
        $this->io = new SymfonyStyle($input, $output);
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {

        $userEmail = $input->getArgument('userEmail');
        $name = $input->getArgument('name');
        $token = $input->getArgument('token');

        // make sure to validate the user data is correct
        $this->validateProjectData($userEmail, $name, $token);

        // create the project
        $project = new Project();
        $project->setUser($this->getUser($userEmail));
        $project->setName($name);
        $project->setToken($token);

        $this->entityManager->persist($project);
        $this->entityManager->flush();

        $this->io->success(sprintf('%s was successfully created: %s (%s)', 'Project', $project->getId(), $project->getName()));

        return 0;
    }

    private function getUser($userEmail): User
    {
        return $this->users->findOneBy(['email' => $userEmail]);
    }

    private function validateProjectData($userEmail, $name, $token): void
    {
        if (empty($userEmail)) {
            throw new InvalidArgumentException('The user email can not be empty.');
        }

        if (empty($name)) {
            throw new InvalidArgumentException('The project name can not be empty.');
        }

        if (empty($token)) {
            throw new InvalidArgumentException('The token can not be empty.');
        }

        // check if a project with the id already exists.
        $existingProject = $this->project->findOneBy(['name' => $name]);
        if (null !== $existingProject) {
            throw new RuntimeException(sprintf('There is already a project registered with the "%s" name.', $name));
        }

        // check if a project with the token already exists.
        $existingProject = $this->project->findOneBy(['token' => $token]);
        if (null !== $existingProject) {
            throw new RuntimeException(sprintf('There is already a project registered with the "%s" token.', $token));
        }

        // check if a user with the user id already exists.
        $existingUser = $this->getUser($userEmail);
        if (!$existingUser) {
            throw new RuntimeException(sprintf('There is not a user registered with the "%s" email.', $userEmail));
        }

        if (1 !== preg_match('/^[aA-zZ_]+$/', $name)) {
            throw new InvalidArgumentException('The project name must contain only lowercase latin characters and underscores.');
        }

        if (1 !== preg_match('/^[aA-zZ_]+$/', $token)) {
            throw new InvalidArgumentException('The token must contain only lowercase latin characters and underscores.');
        }

    }

    /**
     * The command help is usually included in the configure() method, but when
     * it's too long, it's better to define a separate method to maintain the
     * code readability.
     */
    private function getCommandHelp(): string
    {
        return <<<'HELP'
The <info>%command.name%</info> command creates new projects and saves them in the database:
  <info>php %command.full_name%</info> <comment>userEmail projectName projectToken</comment>
HELP;
    }
}
